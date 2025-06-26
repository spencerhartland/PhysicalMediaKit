//
//  PhysicalMedia3DModelView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 6/26/25.
//

import SwiftUI
import RealityKit

// Base 3D model view that handles animation and user interaction.
struct PhysicalMedia3DModelView: View {
    private let attractLoopDelay: Double = 4
    
    @State private var dragGestureActive = false
    @State private var rotationX: Float = 0
    @State private var rotationY: Float = 0
    @State private var viewID = UUID() // By assigning the view a unique ID, refreshing with `triggerViewUpdate` is more reliable.
    @State private var debounceWorkItem: DispatchWorkItem? = nil
    
    // Animation context
    @State private var rotationResetTimer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    @State private var attractLoopTimer = Timer.publish(every: 1/48, on: .main, in: .common).autoconnect()
    @State private var animationStep: Int = 0
    @State private var initialXY: (Float, Float) = (0, 0)
    
    private var entityName: String
    @Binding private var refreshRequested: Bool
    private var makeContent: @MainActor @Sendable (RealityViewCameraContent) async -> Void
    
    public init(
        entity name: String,
        refresh: Binding<Bool>,
        _ make: @escaping @MainActor @Sendable (RealityViewCameraContent) async -> Void
    ) {
        self.entityName = name
        self._refreshRequested = refresh
        self.makeContent = make
    }
    
    var body: some View {
        RealityView { content in
            await makeContent(content)
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
                    dragGestureDidChange(value)
                }
                .onEnded { _ in dragGestureDidEnd() }
        )
        .onAppear {
            // Pause timers when view appears
            rotationResetTimer.upstream.connect().cancel()
            attractLoopTimer.upstream.connect().cancel()
            // Begin attract loop following a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + attractLoopDelay) {
                attractLoopTimer = Timer.publish(every: 1/48, on: .main, in: .common).autoconnect()
            }
        }
        .onChange(of: refreshRequested) { _, requested in
            if requested { refreshView() }
        }
        .onReceive(rotationResetTimer) { _ in
            if !dragGestureActive { resetRotation() }
        }
        .onReceive(attractLoopTimer) { _ in
            if !dragGestureActive { attractLoop() }
        }
    }
    
    // MARK: DragGesture updates -
    
    private func dragGestureDidChange(_ value: DragGesture.Value) {
        dragGestureActive = true
        rotationResetTimer.upstream.connect().cancel()
        attractLoopTimer.upstream.connect().cancel()
        rotationX = Float(value.translation.height / 200)
        rotationY = Float(value.translation.width / 200)
    }
    
    private func dragGestureDidEnd() {
        dragGestureActive = false
        // Prepare to animate back to zero rotation
        initialXY = (rotationX, rotationY)
        animationStep = 0
        rotationResetTimer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    }
    
    // MARK: View updates -
    
    private func refreshView() {
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            viewID = UUID()
        }
        debounceWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    // MARK: Animations -
    
    private func resetRotation() {
        animationStep += 1
        let steps = 60
        let t = Float(animationStep) / Float(steps)
        let easeOut = 1 - pow(1 - t, 3) // cubic easing

        if animationStep < steps {
            rotationX = initialXY.0 * (1 - easeOut)
            rotationY = initialXY.1 * (1 - easeOut)
        } else {
            rotationX = 0
            rotationY = 0
        }
        
        if animationStep >= steps {
            rotationResetTimer.upstream.connect().cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + attractLoopDelay) {
                animationStep = 0
                attractLoopTimer = Timer.publish(every: 1/48, on: .main, in: .common).autoconnect()
            }
        }
    }
    
    private func attractLoop() {
        let steps = 576
        let progress = Float(animationStep) / Float(steps)
        
        if progress < 0.25 {
            animationStep += 1
            rotationY = 0.25 * (progress * 4)
        } else if progress < 0.5 {
            animationStep += 1
            rotationY = (-0.25 * ((progress - 0.25) * 4)) + 0.25
        } else if progress < 0.75 {
            animationStep += 1
            rotationY = -0.25 * ((progress - 0.5) * 4)
        } else {
            animationStep += 1
            rotationY = (0.25 * ((progress - 0.75) * 4)) - 0.25
        }
        
        if progress >= 1 {
            animationStep = 0
        }
    }
}
