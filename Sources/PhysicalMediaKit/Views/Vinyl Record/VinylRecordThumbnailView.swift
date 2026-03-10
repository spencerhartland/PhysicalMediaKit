
//
//  VinylRecordThumbnailView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/6/26.
//

import SwiftUI
import RealityKit

internal struct VinylRecordThumbnailView: View {
    @State private var model = VinylRecordModel()
    
    private var artworkURL: URL?
    private var vinylColor: UIColor
    private var scale: Float
    private var rotationXY: (Float, Float)?
    
    private var thumbnailCacheKey: String {
        let urlString = artworkURL?.absoluteString ?? "no-artwork"
        let colorString = vinylColor.description
        return "vinyl-\(urlString)-\(colorString)"
    }
    
    init(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.vinylColor = vinylColor
        self.scale = scale
        self.rotationXY = rotationXY
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            return await model.loadModel(with: artworkURL, and: vinylColor, at: scale)
        }
    }
}
