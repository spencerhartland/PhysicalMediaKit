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
    private var scale: Float
    private var rotationXY: (Float, Float)?
    
    private var thumbnailCacheKey: String {
        let urlString = artworkURL?.absoluteString ?? "no-artwork"
        return "compact_disc-\(urlString)"
    }
    
    init(
        _ artworkURL: URL?,
        _ scale: Float,
        _ rotationXY: (Float, Float)?,
    ) {
        self.artworkURL = artworkURL
        self.scale = scale
        self.rotationXY = rotationXY
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            return await model.loadModel(with: artworkURL, at: scale)
        }
    }
}
