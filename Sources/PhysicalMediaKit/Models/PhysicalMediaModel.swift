//
//  PhysicalMediaModel.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/13/26.
//

import RealityKit
import SwiftUI

/// The abstracted base model for all physical media.
@MainActor @Observable class PhysicalMediaModel {
    /// The default factor by which to multiply the model scale.
    private let defaultModelScaleFactor: Float = 10.0
    
    /// The name of the entity in the module.
    private var entityName: String
    
    /// Creates a new `PhysicalMediaModel`.
    ///
    /// - Parameters:
    ///     - entityName: The name of the entity in the module to render.
    /// - Returns: The new `PhysicalMediaModel`.
    internal init(named entityName: String) {
        self.entityName = entityName
    }
    
    /// Applies the specified album artwork to the entity.
    ///
    /// - Parameters:
    ///     - artwork: The album artwork texture to apply.
    ///     - entity: The entity to apply the artwork to.
    internal func applyArtwork(_ artwork: TextureResource, to entity: Entity) { return }
    
    /// Applies the specified color to the entity.
    ///
    /// - Parameters:
    ///     - mediaColor: The color to apply.
    ///     - entity: The entity to apply the color to.
    internal func applyColor(_ mediaColor: UIColor, to entity: Entity) { return }
    
    /// Loads an entity and applies customizations.
    ///
    /// - Parameters:
    ///     - artworkURL: The URL from which to retrieve album artwork.
    ///     - color: The color of the physical media.
    ///     - scale: The entity's scale.
    /// - Returns: The loaded entity with customizations applied.
    internal func loadModel(with artworkURL: URL?, and color: UIColor? = nil, at scale: Float = 1.0) async -> Entity? {
        do {
            var entity = try await self.loadEntity(with: entityName, at: scale)
            if let artworkURL, let artwork = await fetchArtwork(from: artworkURL) {
                applyArtwork(artwork, to: entity)
            }
            if let color { applyColor(color, to: entity) }
            return entity
        } catch {
            Log.general.error("Failed to load model: \(error)")
            return nil
        }
    }
    
    // MARK: - Private
    
    /// Returms a texture generated from the album artwork retrieved from the specified URL.
    ///
    /// - Parameters:
    ///     - artworkURL: The remote URL from which to retrieve the album artwork.
    /// - Returns: The texture generated from the album artwork.
    private func fetchArtwork(from artworkURL: URL) async -> TextureResource? {
        return await ArtworkCache.shared.loadTexture(for: artworkURL)
    }
    
    /// Loads a named entity from the current module at the specified scale.
    ///
    /// - Parameters:
    ///     - name: The name of the entity to load.
    ///     - scale: The entity's scale.
    /// - Returns: The entity with the specified name.
    private func loadEntity(with name: String, at scale: Float) async throws -> Entity {
        let entity = try await Entity(named: name, in: .module)
        entity.name = name
        let modelScale = scale * defaultModelScaleFactor
        await entity.setScale(.init(repeating: modelScale), relativeTo: entity)
        await entity.generateCollisionShapes(recursive: true)
        return entity
    }
}
