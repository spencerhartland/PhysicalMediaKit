//
//  ArtworkCache.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/9/26.
//

import Foundation
import RealityKit
import CoreGraphics

actor ArtworkCache {
    private let cache = NSCache<NSURL, CGImage>()
    private var inFlight: Set<URL> = []
    
    static internal let shared = ArtworkCache()
    
    internal func loadTexture(for url: URL) async -> TextureResource? {
        // Fetch the texture from the remote URL
        do {
            try await load(url: url)
        } catch {
            return nil
        }
        
        // Retrieve the texture from cache
        if let texture = await texture(for: url) {
            return texture
        } else {
            // If fetching the texture failed, clean cache
            cache.removeObject(forKey: url as NSURL)
            return nil
        }
    }
    
    internal func removeAllArtworks() { cache.removeAllObjects() }
    
    private func texture(for url: URL) async -> TextureResource? {
        guard let image = cache.object(forKey: url as NSURL) else { return nil }
        return try? await TextureResource(image: image, options: .init(semantic: .color))
    }

    private func load(url: URL) async throws {
        if cache.object(forKey: url as NSURL) != nil || inFlight.contains(url) { return }
        inFlight.insert(url)
        defer { inFlight.remove(url) }

        do {
            let image = try await Network.fetchAlbumArt(from: url)
            cache.setObject(image, forKey: url as NSURL)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            print("Album art load failed: \(error)")
        }
    }
}

