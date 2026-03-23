//
//  ThumbnailRenderer.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/4/26.
//

import RealityKit
import UIKit
import Metal

/// Renders thumbnail images from RealityKit entities.
@MainActor internal final class ThumbnailRenderer {
    /// The renderer's Metal device.
    private let device: MTLDevice?
    /// The queue of commands for the Metal device.
    private let commandQueue: MTLCommandQueue?
    /// Renders `RealityKit` entities.
    private var renderer: RealityRenderer?
    /// The renderer's camera.
    private let camera = PerspectiveCamera()
    /// The keys of any currently rendering thumbnails.
    private var inFlight: Set<String> = []
    
    private var queue: [CheckedContinuation<Void, Never>] = []
    private var isRendering: Bool = false
    
    static internal let shared = ThumbnailRenderer()
    
    /// Creates a new `ThumbnailRenderer`.
    ///
    /// - Returns: The new `VinylRecordModel`.
    init() {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue()
        else {
            Log.general.error("Failed to create Metal device and / or command queue.")
            self.device = nil
            self.commandQueue = nil
            return
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        do {
            let renderer = try RealityRenderer()
            
            Task { await configureLighting(for: renderer) }
            
            // Set background color (transparent or solid)
            renderer.cameraSettings.colorBackground = .color(
                .init(srgbRed: 0, green: 0, blue: 0, alpha: 0)
            )
            
            // Set up camera
            camera.camera.fieldOfViewInDegrees = 45
            camera.position = [0, 0, 0.4]
            camera.look(at: .zero, from: camera.position, relativeTo: nil)
            
            renderer.entities.append(camera)
            renderer.activeCamera = camera
            
            self.renderer = renderer
        } catch {
            Log.general.error("Failed to create RealityRenderer: \(error)")
            self.renderer = nil
        }
    }
    
    func thumbnail(with key: String) async -> UIImage? {
        return await ThumbnailCache.shared.retrieveThumbnail(with: key)
    }
    
    /// Renders a thumbnail of the specified RealityKit entity.
    ///
    /// - Parameters:
    ///     - entity: The subject of the thumbnail.
    ///     - key: A unique key to identify the thumbnail.
    ///     - rotationXY: A tuple containing the entity's rotation values (from 0.0 to 1.0) for
    ///       the X and Y axes.
    /// - Returns: The thumbnail, if it was able to be created. Otherwise, nil.
    func thumbnail(
        for entity: Entity,
        with key: String,
        and rotationXY: (Float, Float)?
    ) async -> UIImage? {
        guard !inFlight.contains(key) else { return nil }
        inFlight.insert(key)
        defer { inFlight.remove(key) }
        
        let image = await render(entity, with: rotationXY)
        if let image { await ThumbnailCache.shared.cache(image, for: key) }
        
        return image
    }
    
    /// Configures lighting for the `RealityKit` scene.
    ///
    /// - Parameters:
    ///     - renderer: The `RealityRenderer` responsible for rendering the scene.
    private func configureLighting(for renderer: RealityRenderer) async {
        // Set up Image-Based Lighting
        // Get image from bundle
        guard let url = Bundle.module.url(forResource: "studio", withExtension: "exr"),
              let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            Log.general.info("IBL setup failed: unable to retrieve resource from bundle.")
            return
        }
        // Create lighting resource from image
        if let envResource = try? await EnvironmentResource(equirectangular: cgImage) {
            guard renderer.lighting.resource == nil else { return }
            renderer.lighting.resource = envResource
            renderer.lighting.intensityExponent = 1
        } else {
            Log.general.info("IBL setup failed: unable to create environment resource.")
        }
        
        // Set up virtual lighting
        let light = Entity()
        var lightComponent = DirectionalLightComponent()
        lightComponent.intensity = 1500
        light.components.set(lightComponent)
        light.look(at: .zero, from: [-4, 3, 4], relativeTo: nil)
        renderer.entities.append(light)
        
        let light2 = Entity()
        var light2Component = DirectionalLightComponent()
        light2Component.intensity = 500
        light2.components.set(light2Component)
        light2.look(at: .zero, from: [-60, 20, 12], relativeTo: nil)
        renderer.entities.append(light2)
    }
    
    /// Renders a Metal texture from the specified RealityKit entity and converts the texture to an image.
    ///
    /// - Parameters:
    ///     - entity: The subject of the image.
    ///     - rotationXY: A tuple containing the entity's rotation values (from 0.0 to 1.0) for
    ///       the X and Y axes.
    /// - Returns: The image of the entity, if it was able to be created. Otherwise, nil.
    private func render(_ entity: Entity, with rotationXY: (Float, Float)?) async -> UIImage? {
        await lock()
        defer { unlock() }
        
        guard let renderer, let device, let commandQueue else { return nil }
        
        let rotX = simd_quatf(angle: rotationXY?.0 ?? 0, axis: SIMD3<Float>(1, 0, 0))
        let rotY = simd_quatf(angle: rotationXY?.1 ?? 0, axis: SIMD3<Float>(0, 1, 0))
        entity.transform.rotation = rotX * rotY
        
        renderer.entities.append(entity)
        defer { entity.removeFromParent() }
        
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: ThumbnailCache.thumbnailSize,
            height: ThumbnailCache.thumbnailSize,
            mipmapped: false
        )
        textureDesc.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        guard let colorTexture = device.makeTexture(descriptor: textureDesc),
              let event = device.makeEvent() else {
            return nil
        }
        
        do {
            let descriptor = RealityRenderer.CameraOutput.Descriptor.singleProjection(
                colorTexture: colorTexture
            )
            
            try renderer.updateAndRender(
                deltaTime: 0.0,
                cameraOutput: .init(descriptor),
                whenScheduled: { _ in },
                onComplete: { _ in },
                actionsBeforeRender: [],
                actionsAfterRender: [
                    .signal(event, value: 1)
                ]
            )
        } catch {
            Log.general.error("Thumbnail render failed: \(error)")
            return nil
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return nil
        }
        commandBuffer.encodeWaitForEvent(event, value: 1)
        commandBuffer.commit()
        await commandBuffer.completed()
        
        return textureToImage(colorTexture)
    }
    
    /// Creates an image from the specified Metal texture.
    ///
    /// - Parameters:
    ///     - texture: The texture to convert.
    /// - Returns: The image of the texture, if it was able to be created. Otherwise, nil.
    private func textureToImage(_ texture: MTLTexture) -> UIImage? {
        let width = texture.width
        let height = texture.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * height)
        texture.getBytes(
            &pixelData,
            bytesPerRow: bytesPerRow,
            from: MTLRegion(
                origin: MTLOrigin(x: 0, y: 0, z: 0),
                size: MTLSize(width: width, height: height, depth: 1)
            ),
            mipmapLevel: 0
        )
        
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let b = pixelData[i]
            let r = pixelData[i + 2]
            pixelData[i] = r
            pixelData[i + 2] = b
        }
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func lock() async {
        if isRendering {
            await withCheckedContinuation { continuation in
                queue.append(continuation)
            }
        }
        isRendering = true
    }

    private func unlock() {
        if let next = queue.first {
            queue.removeFirst()
            next.resume()  // Next render takes over the lock
        } else {
            isRendering = false
        }
    }
}
