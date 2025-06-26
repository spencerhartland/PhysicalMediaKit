//
//  Network.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 6/26/25.
//

import Foundation
import UIKit
import RealityKit

final class Network {
    static func fetchAlbumArt(from url: URL) async throws -> TextureResource {
        // Download album art
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else {
            throw PhysicalMediaError.failedToLoadAlbumArt
        }
        
        // Generate texture from album art
        guard let texture = try? await TextureResource(image: cgImage, options: .init(semantic: .color)) else {
            throw PhysicalMediaError.failedToGenerateTextureFromImage
        }
        
        return texture
    }
}
