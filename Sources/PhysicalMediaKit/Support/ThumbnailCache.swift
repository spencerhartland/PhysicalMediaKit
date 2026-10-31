//
//  ThumbnailCache.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/4/26.
//

import CryptoKit
import os
import RealityKit
import UIKit

/// A cache to store thumbnails.
internal actor ThumbnailCache {
    /// The maximum number of thumbnails allowed on disk.
    private static let maxThumbnailCount = 64
    /// The name of the disk cache subdirectory.
    private static let diskCacheDirectoryName = "com.spencerhartland.PhysicalMediaKit.thumbnails"
    
    /// A global cache for thumbnails.
    internal static let shared = ThumbnailCache()
    /// An internal cache for thumbnails.
    private let cache = NSCache<NSString, UIImage>()
    
    private static let configuredDiskCacheURL = OSAllocatedUnfairLock<URL?>(initialState: nil)
    private static var diskCacheURL: URL? {
        ThumbnailCache.configuredDiskCacheURL.withLock { $0 }
    }

    /// Creates a new `ThumbnailCache`.
    ///
    /// - Returns: The new `ThumbnailCache`.
    private init() {
        guard ThumbnailCache.diskCacheURL == nil else { return }
        
        if let cachesDirectory = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first {
            ThumbnailCache.configure(with: cachesDirectory)
        } else {
            Log.general.error("Failed to unwrap url for caches directory.")
        }
    }
    
    internal static func configure(with baseURL: URL) {
        let cacheURL = baseURL.appendingPathComponent(
            ThumbnailCache.diskCacheDirectoryName,
            isDirectory: true
        )
        do {
            try FileManager.default.createDirectory(
                at: cacheURL,
                withIntermediateDirectories: true
            )
            
            configuredDiskCacheURL.withLock { $0 = cacheURL }
        } catch {
            Log.general.error("Failed to create cache directory on disk: \(error)")
        }
    }
    
    private static func hashString(for string: String) -> String {
        let stringData = Data(string.utf8)
        let hash = SHA256.hash(data: stringData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    internal static func cacheKey(
        for mediaType: MediaType,
        artworkURL: URL?,
        mediaColor: UIColor?,
        scale: Float,
        rotationXY: (Float, Float)?,
    ) -> String {
        let mediaTypeString: String = mediaType.rawValue
        let urlString: String = artworkURL?.absoluteString ?? "no_artwork"
        let colorString: String? = mediaColor?.description
        let scaleString: String = String(scale)
        let rotationXYString: String? = {
            if let rotationXY {
                return "\(rotationXY.0)_\(rotationXY.1)"
            } else {
                return nil
            }
        }()
        
        let components: [String?] = [
            mediaTypeString,
            urlString,
            colorString,
            scaleString,
            rotationXYString,
        ]
        
        var key: String = ""
        for component in components {
            if let component { key.append(component) }
        }
        key = hashString(for: key)
        return key
    }
    
    internal static func thumbnailFromDisk(for key: String) -> UIImage? {
        guard let thumbnailURL = ThumbnailCache.diskFileURL(for: key),
              FileManager.default.fileExists(atPath: thumbnailURL.path()),
              let thumbnailData = try? Data(contentsOf: thumbnailURL)
        else {
            return nil
        }
        
        return UIImage(data: thumbnailData)
    }
    
    /// Adds the thumbnail to both the in-memory and disk caches with the specified key.
    ///
    /// - Parameters:
    ///     - thumbnail: The thumbnail to cache.
    ///     - key: The identifying string to associate with the thumbnail in the cache.
    internal func cache(_ thumbnail: UIImage, for key: String) {
        // Write to in-memory cache
        cache.setObject(thumbnail, forKey: key as NSString)
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
    internal func retrieveThumbnail(with key: String) -> UIImage? {
        // 1. Check in-memory cache
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        
        // 2. Check disk cache
        if let image = readFromDisk(for: key) {
            // Promote to in-memory cache
            cache.setObject(image, forKey: key as NSString)
            return image
        }
        
        return nil
    }
    
    /// Removes the thumbnail associated with the specified key from both caches.
    ///
    /// - Parameters:
    ///     - key: The key associated with the thumbnail to remove.
    internal func removeThumbnail(with key: String) {
        cache.removeObject(forKey: key as NSString)
        removeFromDisk(for: key)
    }
    
    /// Removes all thumbnail images from both caches.
    internal func removeAllThumbnails() {
        cache.removeAllObjects()
        clearDiskCache()
    }
    
    // MARK: - Disk Operations
    
    /// Returns the full file URL for the given cache key, if the disk cache is available.
    ///
    /// - Parameters:
    ///     - key: The cache key.
    /// - Returns: The file URL, or nil if the disk cache is unavailable.
    private static func diskFileURL(for key: String) -> URL? {
        let filename = key + ".png"
        return ThumbnailCache.diskCacheURL?.appendingPathComponent(filename)
    }
    
    /// Writes a thumbnail image to disk as PNG data.
    ///
    /// - Parameters:
    ///     - image: The thumbnail to write.
    ///     - key: The cache key.
    private func writeToDisk(_ image: UIImage, for key: String) {
        guard let url = ThumbnailCache.diskFileURL(for: key) else { return }
        
        do {
            guard let data = image.pngData() else {
                throw PhysicalMediaError.failedToGetDataFromImage
            }
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
        guard let url = ThumbnailCache.diskFileURL(for: key),
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
        guard let url = ThumbnailCache.diskFileURL(for: key) else { return }
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Removes all thumbnails from the disk cache.
    private func clearDiskCache() {
        guard let url = ThumbnailCache.diskCacheURL else { return }
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
    
    /// Evicts the least recently used thumbnails from disk when the file count exceeds the limit.
    private func evictDiskCacheIfNeeded() {
        guard let url = ThumbnailCache.diskCacheURL else { return }
        
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return }
        
        guard files.count > ThumbnailCache.maxThumbnailCount else { return }
        
        // Sort by modification date, oldest first
        let sorted = files.sorted { a, b in
            let dateA = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            let dateB = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            return dateA < dateB
        }
        
        // Remove oldest files until we're back at the limit
        let countToRemove = sorted.count - ThumbnailCache.maxThumbnailCount
        for file in sorted.prefix(countToRemove) {
            try? fm.removeItem(at: file)
        }
    }
}
