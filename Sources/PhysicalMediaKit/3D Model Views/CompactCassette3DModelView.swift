//
//  ContentView.swift
//  TestingModel3D
//
//  Created by Spencer Hartland on 4/5/25.
//

import SwiftUI
import RealityKit

@MainActor
struct CompactCassette3DModelView: View {
    private let entityName = "cassette"
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
    private let albumArtParameterName = "albumArt"
    private let cassetteColorParameterName = "cassetteColor"
    private let cassetteOpacityParameterName = "cassetteOpacity"
    private let defaultModelScaleFactor: Float = 20.0
    
    @State private var modelShouldRefresh: Bool = false
    @State private var refreshWorkItem: DispatchWorkItem? = nil
    
    var albumArtURL: URL
    var cassetteColor: Color
    var modelScaleFactor: Float
    
    public init(
        _ albumArtURL: URL,
        _ cassetteColor: Color,
        _ scale: Float = 1.0
    ) {
        self.albumArtURL = albumArtURL
        self.cassetteColor = cassetteColor
        self.modelScaleFactor = scale * defaultModelScaleFactor
    }
    
    var body: some View {
        PhysicalMedia3DModelView(entity: entityName, refresh: $modelShouldRefresh) { content in
            if let entity = try? await Entity(named: entityName, in: .module) {
                entity.name = entityName
                entity.setScale(.init(x: modelScaleFactor, y: modelScaleFactor, z: modelScaleFactor), relativeTo: entity)
                entity.generateCollisionShapes(recursive: true)
                await updateCoverMaterial(for: entity)
                updateCassetteMaterial(for: entity)
                content.add(entity)
            }
        }
        .onChange(of: albumArtURL) { _, _ in
            requestModelRefresh()
        }
        .onChange(of: cassetteColor) { _, _ in
            requestModelRefresh()
        }
        .onChange(of: modelScaleFactor) { _, _ in
            requestModelRefresh()
        }
    }
    
    private func requestModelRefresh() {
        refreshWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            modelShouldRefresh = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                modelShouldRefresh = false
            }
        }
        refreshWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    private func updateCoverMaterial(for parent: Entity) async {
        if let cover = parent.findEntity(named: "Cover") {
            do {
                let texture = try await Network.fetchAlbumArt(from: albumArtURL)
                
                // Apply texture to cassette cover
                try cover.modifyMaterials { material in
                    guard var paper = material as? ShaderGraphMaterial else {
                        throw PhysicalMediaError.failedToLoadMaterial
                    }
                    
                    try paper.setParameter(
                        name: albumArtParameterName,
                        value: .textureResource(texture)
                    )
                    
                    return paper
                }
            } catch {
                print("CompactCassette3DModelView.updateCoverMaterial - \(error.localizedDescription)")
            }
        }
    }
    
    private func updateCassetteMaterial(for parent: Entity) {
        for partName in cassetteParts {
            if let part = parent.findEntity(named: partName) {
                do {
                    try part.modifyMaterials { material in
                        guard var plastic = material as? ShaderGraphMaterial else {
                            throw PhysicalMediaError.failedToLoadMaterial
                        }
                        
                        try plastic.setParameter(
                            name: cassetteColorParameterName,
                            value: .color(UIColor(cassetteColor))
                        )
                        try plastic.setParameter(
                            name: cassetteOpacityParameterName,
                            value: .float(cassetteColor.resolve(in: .init()).opacity)
                        )
                        
                        return plastic
                    }
                } catch {
                    print("CompactCassette3DModelView.updateCassetteMaterial - \(error.localizedDescription)")
                }
            }
        }
    }
}
