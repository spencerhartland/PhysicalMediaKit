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
    private var inFlight: [URL:Task<CGImage?, Never>] = [:]
    
    static internal let shared = ArtworkCache()
    
    internal func loadTexture(for url: URL) async -> TextureResource? {
        guard let image = await loadImage(from: url) else { return nil }
        return try? await TextureResource(image: image, options: .init(semantic: .color))
    }
    
    internal func removeAllArtworks() { cache.removeAllObjects() }
    
    private func loadImage(from url: URL) async -> CGImage? {
        if let cached = cache.object(forKey: url as NSURL) { return cached }
        if let existing = inFlight[url] { return await existing.value }
        
        let task = Task<CGImage?, Never> {
            try? await Network.fetchAlbumArt(from: url)
        }
        inFlight[url] = task
        let result = await task.value
        inFlight[url] = nil
        if let result { cache.setObject(result, forKey: url as NSURL) }
        return result
    }
}

