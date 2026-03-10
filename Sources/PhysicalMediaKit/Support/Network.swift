//
//  Network.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 6/26/25.
//

import Foundation
import UIKit
import RealityKit
import CoreGraphics

/// Provides methods to fetch resources.
internal final class Network {
    /// The maximum image width / height, in pixels.
    private static let maxImageSize: Int = 1024
    
    /// Fetches album artwork from the specified URL.
    ///
    /// - Parameters:
    ///     - url: The URL at which the album artwork is located.
    /// - Returns: The album artwork.
    static func fetchAlbumArt(from url: URL) async throws -> CGImage {
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = image(from: data)
        else {
            throw PhysicalMediaError.failedToLoadAlbumArt
        }
        
        return image
    }
    
    /// Creates an image from data.
    ///
    /// - Parameters:
    ///     - data: The image data.
    /// - Returns: The image, if it was able to be created. Otherwise, nil.
    private static func image(from data: Data) -> CGImage? {
        let cfData = data as CFData
        guard let source = CGImageSourceCreateWithData(cfData, nil) else { return nil }
        
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Network.maxImageSize
        ]
        
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}
