//
//  VinylRecordModel.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/12/26.
//

import UIKit
import RealityKit
import Foundation

/// A model implementing funtionality for rendering a 3D model of a vinyl record.
@MainActor @Observable final class VinylRecordModel: PhysicalMediaModel {
    /// The name of the vinyl record entity in the bundle.
    private let vinylRecordEntityName = "vinyl_record"
    /// The name of the vinyl record's sleeve.
    private let vinylRecordSleevePartName = "vinyl_record_jacket_1420_paper"
    /// The name of the vinyl record itself.
    private let vinylRecordVinylPartName = "vinyl_record_jacket_1420_plastic"
    /// The name of the album art parameter.
    private let albumArtParameterName = "albumArt"
    /// The name of the vinyl color parameter.
    private let vinylColorParameterName = "vinylColor"
    /// The name of the vinyl opacity parameter.
    private let vinylOpacityParameterName = "vinylOpacity"
    
    /// Creates a new `VinylRecordModel`.
    ///
    /// - Returns: The new `VinylRecordModel`.
    internal init() {
        super.init(named: vinylRecordEntityName)
    }
    
    /// Applies the specified album artwork to the vinyl record's sleeve.
    ///
    /// - Parameters:
    ///     - artwork: The album artwork texture to apply.
    ///     - entity: The entity to apply the artwork to.
    override func applyArtwork(_ artwork: TextureResource, to entity: Entity) {
        guard let sleeve = entity.findEntity(named: vinylRecordSleevePartName) else { return }

        do {
            try sleeve.modifyMaterials { material in
                guard var paper = material as? ShaderGraphMaterial else {
                    throw PhysicalMediaError.failedToLoadMaterial
                }
                
                try paper.setParameter(
                    name: albumArtParameterName,
                    value: .textureResource(artwork))
                
                return paper
            }
        } catch {
            Log.general.error(
                "VinylRecordModel.applyArtwork(_:to:) – Failed to apply album art: \(error)")
        }
    }
    
    /// Applies the specified color to the vinyl record.
    ///
    /// - Parameters:
    ///     - mediaColor: The color to apply.
    ///     - entity: The entity to apply the color to.
    override func applyColor(_ mediaColor: UIColor, to entity: Entity) {
        guard let vinyl = entity.findEntity(named: vinylRecordVinylPartName) else { return }
        
        do {
            try vinyl.modifyMaterials { material in
                guard var plastic = material as? ShaderGraphMaterial else {
                    throw PhysicalMediaError.failedToLoadMaterial
                }
                
                try plastic.setParameter(name: vinylColorParameterName, value: .color(mediaColor))
                
                // Get opacity
                var opacity: CGFloat = 1.0
                mediaColor.getRed(nil, green: nil, blue: nil, alpha: &opacity)
                try plastic.setParameter(
                    name: vinylOpacityParameterName,
                    value: .float(Float(opacity)))
                
                return plastic
            }
        } catch {
            Log.general.error(
                "VinylRecordModel.apply(_:to:) – Failed to apply media color: \(error)")
        }
    }
}

