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
    
    private var thumbnailCacheKey: String {
        let urlString = artworkURL?.absoluteString ?? "no-artwork"
        let colorString = cassetteColor.description
        return "compact_cassette-\(urlString)-\(colorString)"
    }
    
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
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            return try? await model.loadEntity(with: artworkURL, and: cassetteColor, at: scale)
        }
    }
}
