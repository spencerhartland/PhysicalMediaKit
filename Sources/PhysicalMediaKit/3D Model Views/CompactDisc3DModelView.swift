//
//  CompactDisc3DModelView.swift
//  TestingModel3D
//
//  Created by Spencer Hartland on 4/5/25.
//

import SwiftUI
import RealityKit

struct CompactDisc3DModelView: View {
    private let entityName = "cd"
    private let cdBookletFrontPartName = "Booklet_Front"
    private let cdBookletBackPartName = "Booklet_Back"
    private let albumArtParameterName = "albumArt"
    private let defaultModelScaleFactor: Float = 10.0
    
    @State private var modelShouldRefresh: Bool = false
    @State private var refreshWorkItem: DispatchWorkItem? = nil
    
    var albumArtURL: URL
    var modelScaleFactor: Float
    
    public init(
        _ albumArtURL: URL,
        _ scale: Float
    ) {
        self.albumArtURL = albumArtURL
        self.modelScaleFactor = scale * defaultModelScaleFactor
    }
    
    var body: some View {
        PhysicalMedia3DModelView(entity: entityName, refresh: $modelShouldRefresh) { content in
            if let entity = try? await Entity(named: entityName, in: .module) {
                entity.name = entityName
                entity.setScale(.init(x: modelScaleFactor, y: modelScaleFactor, z: modelScaleFactor), relativeTo: entity)
                entity.generateCollisionShapes(recursive: true)
                await updateBookletMaterial(for: entity)
                content.add(entity)
            }
        }
        .onChange(of: albumArtURL) { _, _ in
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
    
    private func updateBookletMaterial(for cd: Entity) async {
        if let bookletFront = cd.findEntity(named: cdBookletFrontPartName),
           let bookletBack = cd.findEntity(named: cdBookletBackPartName) {
            do {
                let texture = try await Network.fetchAlbumArt(from: albumArtURL)
                
                try bookletFront.modifyMaterials { material in
                    guard var paper = material as? ShaderGraphMaterial else {
                        throw PhysicalMediaError.failedToLoadMaterial
                    }
                    
                    try paper.setParameter(
                        name: albumArtParameterName,
                        value: .textureResource(texture)
                    )
                    
                    return paper
                }
                
                try bookletBack.modifyMaterials { material in
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
                print("CompactDisc3DModelView.updateBookletMaterial - \(error.localizedDescription)")
            }
        }
    }
}
