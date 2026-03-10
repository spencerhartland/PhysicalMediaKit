//
//  PhysicalMedia3DModelView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 6/26/25.
//

import SwiftUI
import RealityKit
import Combine

// Base 3D model view that handles animation and user interaction.
internal struct PhysicalMedia3DModelView: View {
    private let attractLoopDelay: Double = 4
    
    @State private var dragGestureActive = false
    @State private var rotationX: Float = 0
    @State private var rotationY: Float = 0
    
    // Animation context
    @State private var shouldAnimate: Bool = true
    @State private var rotationResetTimer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var attractLoopTimer: Publishers.Autoconnect<Timer.TimerPublisher>?
    @State private var animationStep: Int = 0
    @State private var initialXY: (Float, Float) = (0, 0)
    
    private var entityName: String
    private var homeXY: (Float, Float)
    private var makeContent: @MainActor @Sendable (RealityViewCameraContent) async -> Void
    private var updateContent: @MainActor @Sendable (RealityViewEntityCollection.Element) -> Void
    
    init(
        entity name: String,
        rotationXY: (Float, Float)? = nil,
        _ make: @escaping @MainActor @Sendable (RealityViewCameraContent) async -> Void,
        update: @escaping @MainActor @Sendable (RealityViewEntityCollection.Element) -> Void = { _ in }
    ) {
        entityName = name
        
        if let (rotX, rotY) = rotationXY {
            homeXY = (rotX, rotY)
            
            shouldAnimate = false
            rotationX = rotX
            rotationY = rotY
        } else {
            homeXY = (0, 0)
        }
        
        makeContent = make
        updateContent = update
    }
    
    var body: some View {
        RealityView { content in
            await makeContent(content)
        } update: { content in
            if let entity = content.entities.first(where: { $0.name == entityName }) {
                updateContent(entity)
                let rotX = simd_quatf(angle: rotationX, axis: SIMD3<Float>(1, 0, 0))
                let rotY = simd_quatf(angle: rotationY, axis: SIMD3<Float>(0, 1, 0))
                entity.transform.rotation = rotX * rotY
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragGestureDidChange(value)
                }
                .onEnded { _ in dragGestureDidEnd() }
        )
        .onAppear {
            // Begin attract loop following a delay
            if shouldAnimate {
                DispatchQueue.main.asyncAfter(deadline: .now() + attractLoopDelay) {
                    attractLoopTimer = Timer.publish(every: 1/48, on: .main, in: .common).autoconnect()
                }
            }
        }
        .onDisappear {
            rotationResetTimer?.upstream.connect().cancel()
            rotationResetTimer = nil
            attractLoopTimer?.upstream.connect().cancel()
            attractLoopTimer = nil
        }
        .onReceive(rotationResetTimer ?? Timer.publish(every: .infinity, on: .main, in: .common).autoconnect()) { _ in
            if rotationResetTimer != nil && !dragGestureActive {
                resetRotation()
            }
        }
        .onReceive(attractLoopTimer ?? Timer.publish(every: .infinity, on: .main, in: .common).autoconnect()) { _ in
            if attractLoopTimer != nil && !dragGestureActive && shouldAnimate {
                attractLoop()
            }
        }
    }
    
    // MARK: DragGesture updates -
    
    private func dragGestureDidChange(_ value: DragGesture.Value) {
        dragGestureActive = true
        rotationResetTimer?.upstream.connect().cancel()
        rotationResetTimer = nil
        attractLoopTimer?.upstream.connect().cancel()
        attractLoopTimer = nil
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
    
    // MARK: Animations -
    
    private func resetRotation() {
        animationStep += 1
        let steps = 60
        let t = Float(animationStep) / Float(steps)
        let easeOut = 1 - pow(1 - t, 3) // cubic easing

        if animationStep < steps {
            rotationX = (initialXY.0 * (1 - easeOut)) + (homeXY.0 * t)
            rotationY = (initialXY.1 * (1 - easeOut)) + (homeXY.1 * t)
        } else {
            rotationX = homeXY.0
            rotationY = homeXY.1
        }
        
        if animationStep >= steps {
            rotationResetTimer?.upstream.connect().cancel()
            rotationResetTimer = nil
            if shouldAnimate {
                DispatchQueue.main.asyncAfter(deadline: .now() + attractLoopDelay) {
                    animationStep = 0
                    attractLoopTimer = Timer.publish(every: 1/48, on: .main, in: .common).autoconnect()
                }
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
