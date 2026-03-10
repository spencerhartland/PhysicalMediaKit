//
//  CompactCassetteModel.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/16/26.
//

import SwiftUI
import RealityKit
import Foundation

/// A model implementing funtionality for rendering a 3D model of a compact cassette.
@MainActor @Observable final class CompactCassetteModel: PhysicalMediaModel {
    /// The name of the cassette entity in the bundle.
    private let cassetteEntityName = "cassette"
    /// An array containing the names of all of the cassette's parts.
    private let cassetteParts = [
        "A",
        "B",
        "Cover_1",
        "Cover_Holder",
        "Holder_Glass",
        "Push_1",
        "Push_2",
        "Cover_2",
        "Cover_Holder_1",
        "Holder_Glass_1"
    ]
    /// The name of the album art parameter.
    private let albumArtParameterName = "albumArt"
    /// The name of the cassette color parameter.
    private let cassetteColorParameterName = "cassetteColor"
    /// The name of the cassette opacity parameter.
    private let cassetteOpacityParameterName = "cassetteOpacity"
    
    /// Creates a new `CompactCassetteModel`.
    ///
    /// - Returns: The new `CompactCassetteModel`.
    internal init() {
        super.init(named: cassetteEntityName)
    }
    
    /// Applies the specified album artwork to the cassette's cover.
    ///
    /// - Parameters:
    ///     - artwork: The album artwork texture to apply.
    ///     - entity: The entity to apply the artwork to.
    override func applyArtwork(_ artwork: TextureResource, to entity: Entity) {
        guard let cover = entity.findEntity(named: "Cover") else { return }
        
        do {
            // Apply texture to cassette cover
            try cover.modifyMaterials { material in
                guard var paper = material as? ShaderGraphMaterial else {
                    throw PhysicalMediaError.failedToLoadMaterial
                }
                
                try paper.setParameter(
                    name: albumArtParameterName,
                    value: .textureResource(artwork)
                )
                
                return paper
            }
        } catch {
            print("CompactCassetteModel.apply(_:to:) – Failed to apply album art: \(error)")
        }
    }
    
    /// Applies the specified color to the cassette.
    ///
    /// - Parameters:
    ///     - mediaColor: The color to apply.
    ///     - entity: The entity to apply the color to.
    override func applyColor(_ mediaColor: UIColor, to entity: Entity) {
        for partName in cassetteParts {
            if let part = entity.findEntity(named: partName) {
                do {
                    try part.modifyMaterials { material in
                        guard var plastic = material as? ShaderGraphMaterial else {
                            throw PhysicalMediaError.failedToLoadMaterial
                        }
                        
                        try plastic.setParameter(
                            name: cassetteColorParameterName,
                            value: .color(mediaColor)
                        )
                        
                        // Get opacity
                        var opacity: CGFloat = 1.0
                        mediaColor.getRed(nil, green: nil, blue: nil, alpha: &opacity)
                        try plastic.setParameter(
                            name: cassetteOpacityParameterName,
                            value: .float(Float(opacity))
                        )
                        
                        return plastic
                    }
                } catch {
                    print("CompactCassetteModel.apply(_:to:) – Failed to apply media color: \(error)")
                }
            }
        }
    }
}
