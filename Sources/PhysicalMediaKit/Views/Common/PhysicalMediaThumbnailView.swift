//
//  PhysicalMediaThumbnailView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 2/6/26.
//

import SwiftUI
import RealityKit

internal struct PhysicalMediaThumbnailView: View {
    @State private var thumbnail: UIImage?
    
    private let renderer = ThumbnailRenderer()
    
    private var makeEntity: () async -> Entity?
    private var thumbnailCacheKey: String
    private var rotationXY: (Float, Float)?
    
    init(
        _ thumbnailCacheKey: String,
        _ rotationXY: (Float, Float)?,
        _ makeEntity: @escaping () async -> Entity?,
    ) {
        self.makeEntity = makeEntity
        self.thumbnailCacheKey = thumbnailCacheKey
        self.rotationXY = rotationXY
    }
    
    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Show placeholder
                PlaceholderView()
            }
        }
        .task {
            if let thumbnail = await renderer.thumbnail(with: thumbnailCacheKey) {
                self.thumbnail = thumbnail
            } else {
                guard let entity = await makeEntity() else { return }
                self.thumbnail = await renderer.thumbnail(
                    for: entity,
                    with: thumbnailCacheKey,
                    and: rotationXY
                )
            }
        }
    }
}
