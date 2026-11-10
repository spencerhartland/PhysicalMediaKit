//
//  CompactDiscThumbnailView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/6/26.
//

import SwiftUI

internal struct CompactDiscThumbnailView: View {
    @State private var model = CompactDiscModel()
    
    private var artworkURL: URL?
    private var coverColor: UIColor?
    private var scale: Float
    private var rotationXY: (Float, Float)?
    private var thumbnailCacheKey: String
    
    init(
        _ artworkURL: URL?,
        _ coverColor: UIColor?,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.coverColor = coverColor
        self.scale = scale
        self.rotationXY = rotationXY
        self.thumbnailCacheKey = PhysicalMedia.cacheKey(
            for: .compactDisc,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: nil,
            scale: scale,
            rotationXY: rotationXY
        )
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            do {
                Log.general.debug("CompactDiscThumbnailView - Loading entity...")
                return try await model.loadEntity(
                    with: artworkURL,
                    coverColor: coverColor,
                    scale: scale
                )
            } catch {
                Log.general.error(
                    """
                    CompactDiscThumbnailView - Error while loading model: \(error.localizedDescription)
                    """
                )
                return nil
            }
        }
    }
}
