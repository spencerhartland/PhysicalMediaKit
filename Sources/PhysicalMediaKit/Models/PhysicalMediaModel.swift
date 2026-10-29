//
//  PhysicalMediaModel.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/13/26.
//

import RealityKit
import SwiftUI

/// The abstracted base model for all physical media.
@MainActor
@Observable
internal class PhysicalMediaModel {
    /// The default factor by which to multiply the model scale.
    private let defaultModelScaleFactor: Float = 10.0
    
    private var artworkTask: Task<Void, Never>?
    
    /// The name of the entity in the module.
    private var entityName: String
    
    /// Creates a new `PhysicalMediaModel`.
    ///
    /// - Parameter entityName: The name of the entity in the module to render.
    /// - Returns: The new `PhysicalMediaModel`.
    internal init(named entityName: String) {
        self.entityName = entityName
    }
    
    /// Loads a named entity from the current module at the specified scale.
    ///
    /// - Parameters:
    ///     - artworkURL: The album artwork URL.
    ///     - color: The media color.
    ///     - scale: The entity's scale.
    /// - Returns: The entity with the specified name.
    internal func loadEntity(
        with artworkURL: URL?,
        and color: UIColor? = nil,
        at scale: Float,
    ) async throws -> Entity {
        let entity = try await Entity(named: entityName, in: .module)
        entity.name = entityName
        let modelScale = scale * defaultModelScaleFactor
        entity.setScale(.init(repeating: modelScale), relativeTo: entity)
        entity.generateCollisionShapes(recursive: true)
        if let artworkURL { applyArtwork(from: artworkURL, to: entity) }
        if let color { applyColor(color, to: entity) }
        return entity
    }
    
    internal func applyArtwork(from artworkURL: URL, to entity: Entity) {
        self.artworkTask?.cancel()
        self.artworkTask = Task {
            guard !Task.isCancelled else { return }
            
            if let artwork = await fetchArtwork(from: artworkURL) {
                applyArtwork(artwork, to: entity)
            }
        }
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
    
    /// Returms a texture generated from the album artwork retrieved from the specified URL.
    ///
    /// - Parameter artworkURL: The remote URL from which to retrieve the album artwork.
    /// - Returns: The texture generated from the album artwork.
    private func fetchArtwork(from artworkURL: URL) async -> TextureResource? {
        return await ArtworkCache.shared.loadTexture(for: artworkURL)
    }
}
