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
            if let thumbnail = await ThumbnailCache.shared.retrieveThumbnail(
                with: thumbnailCacheKey
            ) {
                Log.general.debug("PhysicalMediaThumbnailView - Thumbnail retrieved from cache.")
                self.thumbnail = thumbnail
            } else {
                guard let entity = await makeEntity() else {
                    Log.general.debug("PhysicalMediaThumbnailView - Unable to load the entity.")
                    return
                }
                guard !Task.isCancelled else {
                    Log.general.debug("PhysicalMediaThumbnailView - Thumbnail render task cancelled!")
                    return
                }
                Log.general.debug("PhysicalMediaThumbnailView - Rendering thumbnail...")
                self.thumbnail = await ThumbnailRenderer.shared.thumbnail(
                    for: entity,
                    with: thumbnailCacheKey,
                    and: rotationXY
                )
            }
        }
    }
}
