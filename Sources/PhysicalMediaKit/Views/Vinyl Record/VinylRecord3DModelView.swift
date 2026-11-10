//
//  VinylRecord3DModelView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/13/26.
//

import SwiftUI
import RealityKit

internal struct VinylRecord3DModelView: View {
    // Model loader
    @State private var model = VinylRecordModel()
    @State private var entity: Entity?
    
    // Customizable attributes
    private var artworkURL: URL?
    private var vinylColor: UIColor
    private var coverColor: UIColor?
    private var scale: Float
    private var rotationXY: (Float, Float)?
    
    init(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        _ coverColor: UIColor?,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.vinylColor = vinylColor
        self.coverColor = coverColor
        self.scale = scale
        self.rotationXY = rotationXY
    }
    
    var body: some View {
        Group {
            if let entity {
                PhysicalMedia3DModelView(entity: entity.name, rotationXY: rotationXY) { content in
                    content.add(entity)
                }
            } else {
                // Show placeholder
                PlaceholderView()
            }
        }
        .task {
            guard self.entity == nil else { return }
            do {
                self.entity = try await model.loadEntity(
                    with: artworkURL,
                    coverColor: coverColor,
                    mediaColor: vinylColor,
                    scale: scale
                )
            } catch {
                print("Error while loading vinyl record model: \(error.localizedDescription)")
            }
        }
        .onChange(of: artworkURL) {
            if let entity, let artworkURL { model.applyArtwork(from: artworkURL, to: entity) }
        }
        .onChange(of: coverColor) {
            guard artworkURL == nil else { return }
            if let entity, let coverColor { model.applyCover(coverColor, to: entity) }
        }
        .onChange(of: vinylColor) {
            if let entity { model.applyColor(vinylColor, to: entity) }
        }
    }
}
