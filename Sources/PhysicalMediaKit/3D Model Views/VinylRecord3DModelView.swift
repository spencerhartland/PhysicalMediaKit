//
//  ContentView.swift
//  TestingModel3D
//
//  Created by Spencer Hartland on 4/5/25.
//

import SwiftUI
import RealityKit

struct VinylRecord3DModelView: View {
    private let entityName = "vinyl_record"
    private let vinylRecordSleevePartName = "vinyl_record_jacket_1420_paper"
    private let vinylRecordVinylPartName = "vinyl_record_jacket_1420_plastic"
    private let albumArtParameterName = "albumArt"
    private let vinylColorParameterName = "vinylColor"
    private let vinylOpacityParameterName = "vinylOpacity"
    private let defaultModelScaleFactor: Float = 10.0
    
    @State private var modelShouldRefresh: Bool = false
    @State private var refreshWorkItem: DispatchWorkItem? = nil
    
    // Customizable params
    var albumArtURL: URL
    var vinylColor: Color
    var modelScaleFactor: Float
    
    public init(
        _ albumArtURL: URL,
        _ vinylColor: Color,
        _ scale: Float = 1.0
    ) {
        self.albumArtURL = albumArtURL
        self.vinylColor = vinylColor
        self.modelScaleFactor = scale * defaultModelScaleFactor
    }
    
    var body: some View {
        PhysicalMedia3DModelView(entity: entityName, refresh: $modelShouldRefresh) { content in
            if let entity = try? await Entity(named: entityName, in: .module) {
                entity.name = entityName
                entity.setScale(.init(x: modelScaleFactor, y: modelScaleFactor, z: modelScaleFactor), relativeTo: entity)
                entity.generateCollisionShapes(recursive: true)
                await updateSleeveMaterial(for: entity)
                updateVinylMaterial(for: entity)
                content.add(entity)
            }
        }
        .onChange(of: albumArtURL) { _, _ in
            requestModelRefresh()
        }
        .onChange(of: vinylColor) { _, _ in
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
    
    private func updateSleeveMaterial(for parent: Entity) async {
        if let sleeve = parent.findEntity(named: vinylRecordSleevePartName) {
            do {
                let texture = try await Network.fetchAlbumArt(from: albumArtURL)
                
                // Apply texture to vinyl record sleeve
                try sleeve.modifyMaterials { material in
                    guard var paper = material as? ShaderGraphMaterial else {
                        throw PhysicalMediaError.failedToLoadMaterial
                    }
                    
                    try paper.setParameter(name: albumArtParameterName, value: .textureResource(texture))
                    
                    return paper
                }
            } catch {
                print("VinylRecord3DModelView.updateSleeveMaterial – \(error.localizedDescription)")
            }
        }
    }
    
    private func updateVinylMaterial(for parent: Entity) {
        if let vinyl = parent.findEntity(named: vinylRecordVinylPartName) {
            do {
                try vinyl.modifyMaterials { material in
                    guard var plastic = material as? ShaderGraphMaterial else {
                        throw PhysicalMediaError.failedToLoadMaterial
                    }
                    
                    try plastic.setParameter(name: vinylColorParameterName, value: .color(UIColor(vinylColor)))
                    try plastic.setParameter(name: vinylOpacityParameterName, value: .float(vinylColor.resolve(in: .init()).opacity))
                    
                    return plastic
                }
            } catch {
                print("VinylRecord3DModelView.updateVinylMaterial – \(error.localizedDescription)")
            }
        }
    }
}
