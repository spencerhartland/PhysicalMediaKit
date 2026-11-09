
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
    private var coverColor: UIColor?
    private var scale: Float
    private var rotationXY: (Float, Float)?
    private var thumbnailCacheKey: String
    
    init(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        _ coverColor: UIColor?,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.vinylColor = vinylColor
        self.coverColor = coverColor
        self.scale = scale
        self.rotationXY = rotationXY
        self.thumbnailCacheKey = PhysicalMedia.cacheKey(
            for: .vinylRecord,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: vinylColor,
            scale: scale,
            rotationXY: rotationXY,
        )
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            do {
                Log.general.debug("VinylRecordThumbnailView - Loading entity...")
                return try await model.loadEntity(
                    with: artworkURL,
                    coverColor: coverColor,
                    mediaColor: vinylColor,
                    scale: scale
                )
            } catch {
                Log.general.error(
                    """
                    VinylRecordThumbnailView - Error while loading model: \(error.localizedDescription)
                    """
                )
                return nil
            }
        }
    }
}
