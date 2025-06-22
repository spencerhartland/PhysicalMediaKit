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
    private let attractLoopDelay: Double = 4
    
    // Attract loop drag gesture reset stat
    @State private var dragGestureActive = false
    @State private var rotationX: Float = 0
    @State private var rotationY: Float = 0
    @State private var animationTimer: Timer? = nil
    @State private var viewID = UUID()
    @State private var debounceWorkItem: DispatchWorkItem? = nil
    
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
        RealityView { content in
            do {
                let entity = try await Entity(named: entityName, in: .module)
                entity.name = entityName
                entity.setScale(.init(x: modelScaleFactor, y: modelScaleFactor, z: modelScaleFactor), relativeTo: entity)
                entity.generateCollisionShapes(recursive: true)
                await updateSleeveMaterial(for: entity)
                updateVinylMaterial(for: entity)
                content.add(entity)
            } catch {
                print("Unable to load model due to error: \"\(error.localizedDescription)\".")
            }
        } update: { content in
            if let entity = content.entities.first(where: { $0.name == entityName }) {
                let rotX = simd_quatf(angle: rotationX, axis: SIMD3<Float>(1, 0, 0))
                let rotY = simd_quatf(angle: rotationY, axis: SIMD3<Float>(0, 1, 0))
                entity.transform.rotation = rotX * rotY
            }
        }
        .id(viewID)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragGestureActive = true
                    rotationX = Float(value.translation.height / 200)
                    rotationY = Float(value.translation.width / 200)
                }
                .onEnded { _ in
                    dragGestureActive = false
                    resetRotation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + attractLoopDelay) {
                        attractLoop()
                    }
                }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + attractLoopDelay) {
                attractLoop()
            }
        }
        .onChange(of: vinylColor) { _, _ in
            debounceWorkItem?.cancel()
            
            let workItem = DispatchWorkItem {
                viewID = UUID()
            }
            debounceWorkItem = workItem
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        }
    }
    
    // Smoothly transitions the model's rotation to home / zero from current rotation
    private func resetRotation() {
        let duration: TimeInterval = 1
        let steps = 60
        let interval = duration / Double(steps)
        
        var currentStep = 0
        let initialX = rotationX
        let initialY = rotationY
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentStep += 1
            let t = Float(currentStep) / Float(steps)
            let easeOut = 1 - pow(1 - t, 3) // cubic easing

            Task { @MainActor in
                rotationX = initialX * (1 - easeOut)
                rotationY = initialY * (1 - easeOut)
                
                if currentStep >= steps {
                    rotationX = 0
                    rotationY = 0
                    animationTimer?.invalidate()
                    animationTimer = nil
                }
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
        self.animationTimer = timer
    }
    
    private func updateSleeveMaterial(for parent: Entity) async {
        if let sleeve = parent.findEntity(named: vinylRecordSleevePartName) {
            do {
                // Download album art
                guard let (data, _) = try? await URLSession.shared.data(from: albumArtURL),
                      let uiImage = UIImage(data: data),
                      let cgImage = uiImage.cgImage else {
                    throw PhysicalMediaError.failedToLoadAlbumArt
                }
                
                // Generate texture from album art
                guard let texture = try? await TextureResource(image: cgImage, options: .init(semantic: .color)) else {
                    throw PhysicalMediaError.failedToGenerateTextureFromImage
                }
                
                // Apply texture to vinyl record sleeve
                try sleeve.modifyMaterials { material in
                    guard var paper = material as? ShaderGraphMaterial else {
                        throw PhysicalMediaError.failedToLoadMaterial
                    }
                    
                    try paper.setParameter(name: albumArtParameterName, value: .textureResource(texture))
                    
                    return paper
                }
            } catch {
                print("Some error occurred")
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
                print("Some error occurred")
            }
        }
    }
    
    private func attractLoop() {
        let duration: TimeInterval = 12
        let steps = 576
        let interval = duration / Double(steps)
        
        var phaseOneStep = 0
        var phaseTwoStep = 0
        var phaseThreeStep = 0
        var phaseFourStep = 0
        rotationX = 0
        rotationY = 0
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            Task { @MainActor in
                if dragGestureActive {
                    animationTimer?.invalidate()
                    animationTimer = nil
                }
                
                let phaseOneProgress = Float(phaseOneStep) / (Float(steps)/4.0)
                let phaseTwoProgress = Float(phaseTwoStep) / (Float(steps)/4.0)
                let phaseThreeProgress = Float(phaseThreeStep) / (Float(steps)/4.0)
                let phaseFourProgress = Float(phaseFourStep) / (Float(steps)/4.0)
                
                if phaseOneProgress < 1 {
                    phaseOneStep += 1
                    rotationY = 0.25 * phaseOneProgress
                } else if phaseTwoProgress < 1 {
                    phaseTwoStep += 1
                    rotationY = (-0.25 * phaseTwoProgress) + 0.25
                } else if phaseThreeProgress < 1 {
                    phaseThreeStep += 1
                    rotationY = -0.25 * phaseThreeProgress
                } else {
                    phaseFourStep += 1
                    rotationY = (0.25 * phaseFourProgress) - 0.25
                }
                
                if phaseFourProgress >= 1 {
                    phaseOneStep = 0
                    phaseTwoStep = 0
                    phaseThreeStep = 0
                    phaseFourStep = 0
                }
            }
        }
        
        RunLoop.main.add(timer, forMode: .common)
        self.animationTimer = timer
    }
}

//#Preview {
//    VinylRecord3DModelView()
//}
