
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
    private var thumbnailCacheKey: String
    
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
        self.thumbnailCacheKey = PhysicalMedia.cacheKey(
            for: .vinylRecord,
            artworkURL: artworkURL,
            mediaColor: vinylColor,
            scale: scale,
            rotationXY: rotationXY,
        )
    }
    
    var body: some View {
        PhysicalMediaThumbnailView(thumbnailCacheKey, rotationXY) {
            do {
                Log.general.debug("VinylRecordThumbnailView - Loading entity...")
                return try await model.loadEntity(with: artworkURL, and: vinylColor, at: scale)
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

#Preview {
    let artworkURL = URL(string:
        """
        https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/d5/7f/6e/d57f6e8e-068c-ef83-2a62-663e\
        47d3f002/Syro_digital_packshot_RGB_1400.jpg/600x600bb.jpg
        """
    )
    
    VinylRecordThumbnailView(artworkURL, .black, 0.150, nil)
}
