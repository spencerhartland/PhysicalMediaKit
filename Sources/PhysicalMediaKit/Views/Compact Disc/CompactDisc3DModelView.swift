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
    private var albumArtURL: URL?
    private var scale: Float
    private var rotationXY: (Float, Float)?
    
    public init(
        _ albumArtURL: URL?,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.albumArtURL = albumArtURL
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
            self.entity = await model.loadModel(with: albumArtURL, at: scale)
        }
    }
}
