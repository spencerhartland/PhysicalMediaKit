//
//  CompactDiscModel.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/15/26.
//

import UIKit
import RealityKit
import Foundation

/// A model implementing funtionality for rendering a 3D model of a compact disc.
@MainActor @Observable final class CompactDiscModel: PhysicalMediaModel {
    /// The name of the compact disc entity in the bundle.
    private let compactDiscEntityName = "cd"
    /// The name of the front of the compact disc's booklet.
    private let cdBookletFrontPartName = "Booklet_Front"
    /// The name of the back of the compact disc's booklet.
    private let cdBookletBackPartName = "Booklet_Back"
    /// The name of the album art parameter.
    private let albumArtParameterName = "albumArt"
    
    /// Creates a new `CompactDiscModel`.
    ///
    /// - Returns: The new `CompactDiscModel`.
    internal init() {
        super.init(named: compactDiscEntityName)
    }
    
    /// Applies the specified album artwork to the CD's booklet.
    ///
    /// - Parameters:
    ///     - artwork: The album artwork texture to apply.
    ///     - entity: The entity to apply the artwork to.
    override func applyArtwork(_ artwork: TextureResource, to entity: Entity) {
        guard let bookletFront = entity.findEntity(named: cdBookletFrontPartName),
              let bookletBack = entity.findEntity(named: cdBookletBackPartName)
        else { return }
        
        do {
            try bookletFront.modifyMaterials { material in
                guard var paper = material as? ShaderGraphMaterial else {
                    throw PhysicalMediaError.failedToLoadMaterial
                }
                
                try paper.setParameter(
                    name: albumArtParameterName,
                    value: .textureResource(artwork)
                )
                
                return paper
            }
            
            try bookletBack.modifyMaterials { material in
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
            print("CompactDiscModel.apply(_:to:) – Failed to apply album art: \(error)")
        }
    }
}
