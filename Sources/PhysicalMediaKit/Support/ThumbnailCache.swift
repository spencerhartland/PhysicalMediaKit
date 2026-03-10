//
//  ThumbnailCache.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/4/26.
//

import UIKit
import RealityKit
import CryptoKit

/// A cache to store thumbnails.
internal actor ThumbnailCache {
    /// The width / height of the thumbnail in pixels.
    internal static let thumbnailSize = 1024
    /// The number of bytes per pixel in a UIImage.
    private static let bytesPerPixel = 4
    /// The maximum number of thumbnails allowed in the cache.
    private static let maxCount = 50
    /// The cost associated with a single thumbnail in the cache.
    private static let costPerThumbnail = thumbnailSize * thumbnailSize * bytesPerPixel
    /// The maximum cost associated with the thumbnails in the cache.
    private static let maxCost = maxCount * costPerThumbnail
    /// The maximum number of thumbnails allowed on disk.
    private static let maxDiskCount = 64
    /// The name of the disk cache subdirectory.
    private static let diskCacheDirectoryName = "Thumbnails"
    
    /// A global cache for thumbnails.
    internal static let shared = ThumbnailCache()
    /// An internal cache for thumbnails.
    private let cache = NSCache<NSString, UIImage>()
    /// The URL of the on-disk cache directory.
    private let diskCacheURL: URL?

    /// Creates a new `ThumbnailCache`.
    ///
    /// - Returns: The new `ThumbnailCache`.
    private init() {
        cache.totalCostLimit = ThumbnailCache.maxCost
        cache.countLimit = ThumbnailCache.maxCount
        
        // Set up disk cache directory inside Caches/
        if let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let directoryURL = cachesURL.appendingPathComponent(
                ThumbnailCache.diskCacheDirectoryName,
                isDirectory: true
            )
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
                self.diskCacheURL = directoryURL
            } catch {
                Log.general.error("Failed to create disk cache directory: \(error)")
                self.diskCacheURL = nil
            }
        } else {
            self.diskCacheURL = nil
        }
    }
    
    /// Adds the thumbnail to both the in-memory and disk caches with the specified key.
    ///
    /// - Parameters:
    ///     - thumbnail: The thumbnail to cache.
    ///     - key: The identifying string to associate with the thumbnail in the cache.
    func cache(_ thumbnail: UIImage, for key: String) {
        // Write to in-memory cache
        cache.setObject(thumbnail, forKey: key as NSString, cost: ThumbnailCache.costPerThumbnail)
        // Write to disk cache
        writeToDisk(thumbnail, for: key)
    }
    
    /// Retrieves the thumbnail associated with the specified key.
    ///
    /// Checks the in-memory cache first, then falls back to disk. On a disk hit the thumbnail
    /// is promoted back into the in-memory cache to speed up subsequent accesses.
    ///
    /// - Parameters:
    ///     - key: The key associated with the thumbnail to retrieve.
    /// - Returns: The thumbnail, if it exists. Otherwise, nil.
    func retrieveThumbnail(with key: String) -> UIImage? {
        // 1. Check in-memory cache
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // 2. Check disk cache
        if let image = readFromDisk(for: key) {
            // Promote to in-memory cache
            cache.setObject(image, forKey: key as NSString, cost: ThumbnailCache.costPerThumbnail)
            return image
        }
        
        return nil
    }
    
    /// Removes the thumbnail associated with the specified key from both caches.
    ///
    /// - Parameters:
    ///     - key: The key associated with the thumbnail to remove.
    func removeThumbnail(with key: String) {
        cache.removeObject(forKey: key as NSString)
        removeFromDisk(for: key)
    }
    
    /// Removes all thumbnail images from both caches.
    func clearCache() {
        cache.removeAllObjects()
        clearDiskCache()
    }
    
    // MARK: - Disk Operations
    
    /// Returns a filesystem-safe filename for the given cache key by hashing it with SHA256.
    ///
    /// - Parameters:
    ///     - key: The cache key.
    /// - Returns: The hashed filename with a `.png` extension.
    private func diskFileName(for key: String) -> String {
        let hash = SHA256.hash(data: Data(key.utf8))
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        return hashString + ".png"
    }
    
    /// Returns the full file URL for the given cache key, if the disk cache is available.
    ///
    /// - Parameters:
    ///     - key: The cache key.
    /// - Returns: The file URL, or nil if the disk cache is unavailable.
    private func diskFileURL(for key: String) -> URL? {
        diskCacheURL?.appendingPathComponent(diskFileName(for: key))
    }
    
    /// Writes a thumbnail image to disk as PNG data.
    ///
    /// - Parameters:
    ///     - image: The thumbnail to write.
    ///     - key: The cache key.
    private func writeToDisk(_ image: UIImage, for key: String) {
        guard let url = diskFileURL(for: key),
              let data = image.pngData()
        else { return }
        
        do {
            try data.write(to: url, options: .atomic)
            evictDiskCacheIfNeeded()
        } catch {
            Log.general.error("Failed to write thumbnail to disk: \(error)")
        }
    }
    
    /// Reads a thumbnail image from disk.
    ///
    /// Updates the file's modification date on access to support LRU eviction.
    ///
    /// - Parameters:
    ///     - key: The cache key.
    /// - Returns: The thumbnail, if it exists on disk. Otherwise, nil.
    private func readFromDisk(for key: String) -> UIImage? {
        guard let url = diskFileURL(for: key),
              FileManager.default.fileExists(atPath: url.path)
        else { return nil }
        
        // Touch the file to mark it as recently used
        try? FileManager.default.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: url.path
        )
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    /// Removes a single thumbnail from disk.
    ///
    /// - Parameters:
    ///     - key: The cache key.
    private func removeFromDisk(for key: String) {
        guard let url = diskFileURL(for: key) else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Removes all thumbnails from the disk cache.
    private func clearDiskCache() {
        guard let url = diskCacheURL else { return }
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    /// Evicts the least recently used thumbnails from disk when the file count exceeds the limit.
    private func evictDiskCacheIfNeeded() {
        guard let url = diskCacheURL else { return }
        
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return }
        
        guard files.count > ThumbnailCache.maxDiskCount else { return }
        
        // Sort by modification date, oldest first
        let sorted = files.sorted { a, b in
            let dateA = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            let dateB = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            return dateA < dateB
        }
        
        // Remove oldest files until we're back at the limit
        let countToRemove = sorted.count - ThumbnailCache.maxDiskCount
        for file in sorted.prefix(countToRemove) {
            try? fm.removeItem(at: file)
        }
    }
}
