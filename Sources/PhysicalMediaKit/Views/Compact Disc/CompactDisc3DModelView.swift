//
//  CompactDisc3DModelView.swift
//  TestingModel3D
//
//  Created by Spencer Hartland on 4/5/25.
//

import SwiftUI
import RealityKit

internal struct CompactDisc3DModelView: View {
    // Model loader
    @State private var model = CompactDiscModel()
    @State private var entity: Entity?
    
    // Customizable attributes
    private var artworkURL: URL?
    private var scale: Float
    private var rotationXY: (Float, Float)?
    
    public init(
        _ artworkURL: URL?,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
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
                PlaceholderView()
            }
        }
        .task {
            guard self.entity == nil else { return }
            do {
                self.entity = try await model.loadEntity(with: artworkURL, at: scale)
            } catch {
                print("Error while loading compact disc model: \(error.localizedDescription)")
            }
        }
        .onChange(of: artworkURL) {
            if let entity, let artworkURL { model.applyArtwork(from: artworkURL, to: entity) }
        }
    }
}
