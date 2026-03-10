//
//  ContentView.swift
//  TestingModel3D
//
//  Created by Spencer Hartland on 4/5/25.
//

import SwiftUI
import RealityKit

internal struct CompactCassette3DModelView: View {
    // Model loader
    @State private var model = CompactCassetteModel()
    @State private var entity: Entity?
    
    // Customizable attributes
    private var artworkURL: URL?
    private var cassetteColor: UIColor
    private var scale: Float
    private var rotationXY: (Float, Float)?
    
    public init(
        _ artworkURL: URL?,
        _ cassetteColor: UIColor,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.cassetteColor = cassetteColor
        self.scale = scale
        self.rotationXY = rotationXY
    }
    
    var body: some View {
        Group {
            if let entity {
                PhysicalMedia3DModelView(entity: entity.name, rotationXY: rotationXY) { content in
                    content.add(entity)
                } update: { content in
                    model.applyColor(cassetteColor, to: entity)
                }
            } else {
                PlaceholderView()
            }
        }
        .task {
            guard self.entity == nil else { return }
            self.entity = await model.loadModel(with: artworkURL, and: cassetteColor, at: scale)
        }
    }
}
