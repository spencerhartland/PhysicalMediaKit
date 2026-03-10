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
    static let shared = ArtworkCache()

    // NSCache is thread-safe and supports eviction.
    private let cache = NSCache<NSURL, CGImage>()
    private var inFlight: Set<URL> = []

    init() {
        cache.totalCostLimit = 60 * 1024 * 1024
        cache.countLimit = 18
    }
    
    public func loadTexture(for url: URL) async -> TextureResource? {
        await load(url: url)
        return await texture(for: url)
    }
    
    private func texture(for url: URL) async -> TextureResource? {
        guard let image = cache.object(forKey: url as NSURL) else { return nil }
        return try? await TextureResource(image: image, options: .init(semantic: .color))
    }

    private func load(url: URL) async {
        if cache.object(forKey: url as NSURL) != nil || inFlight.contains(url) { return }
        inFlight.insert(url)
        defer { inFlight.remove(url) }

        do {
            let image = try await Network.fetchAlbumArt(from: url)
            
            let cost = image.width * image.height * 4
            cache.setObject(image, forKey: url as NSURL, cost: cost)
        } catch {
            print("Album art load failed: \(error)")
        }
    }
}

