//
//  CompactCassetteThumbnailView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/6/26.
//

import SwiftUI

internal struct CompactCassetteThumbnailView: View {
    @State private var model = CompactCassetteModel()
    
    private var artworkURL: URL?
    private var cassetteColor: UIColor
    private var scale: Float
    private var rotationXY: (Float, Float)?
    private var thumbnailCacheKey: String
    
    init(
        _ artworkURL: URL?,
        _ cassetteColor: UIColor,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.cassetteColor = cassetteColor
        self.scale = scale
        self.rotationXY = rotationXY
        self.thumbnailCacheKey = PhysicalMedia.cacheKey(
            for: .compactCassette,
            artworkURL: artworkURL,
            mediaColor: cassetteColor,
            scale: scale,
            rotationXY: rotationXY
        )
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            do {
                Log.general.debug("CompactCassetteThumbnailView - Loading entity...")
                return try await model.loadEntity(with: artworkURL, and: cassetteColor, at: scale)
            } catch {
                Log.general.error(
                    """
                    CompactCassetteThumbnailView - Error while loading model: \
                    \(error.localizedDescription)
                    """
                )
                return nil
            }
        }
    }
}
