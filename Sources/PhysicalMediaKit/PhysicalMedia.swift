//
//  PhysicalMedia.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 5/7/25.
//

import SwiftUI
import CryptoKit

/// Provides methods to render 3D models of common physical media.
@MainActor
public struct PhysicalMedia {
    @usableFromInline
    static let defaultVinylRecordThumbnailScale: Float = 0.125
    @usableFromInline
    static let defaultCompactDiscThumbnailScale: Float = 0.125
    @usableFromInline
    static let defaultCompactCassetteThumbnailScale: Float = 0.250
    
    // MARK: 3D Model Views -
    
    /// Creates a view of an optionally animated 3D model of a vinyl record partially
    /// pulled from its sleeve.
    ///
    /// The model's attract loop animation is controlled by the `rotationXY` parameter. If no
    /// value is specified for `rotationXY`, the model will be use default rotation values and
    /// will run the attract loop animation. If a value is specified for `rotationXY`, the
    /// model will use the specified rotation values and will not run the attract loop. Response
    /// to drag gestures is not affected by `rotationXY`.
    ///
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - vinylColor: The approximate color of the vinyl, including opacity.
    ///     - scale: The scale (from 0.0 to 1.0) at which to display the model.
    ///     - rotationXY: A tuple containing the rotation values (from 0.0 to 1.0) for the
    ///       X and Y axes.
    public static func vinylRecord(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        _ coverColor: UIColor? = nil,
        scale: Float = 1.0,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        VinylRecord3DModelView(artworkURL, vinylColor, coverColor, scale, rotationXY)
    }
    
    /// Creates a view of an optionally animated 3D model of a compact disc inside of its
    /// partially open case.
    ///
    /// The model's attract loop animation is controlled by the `rotationXY` parameter. If no
    /// value is specified for `rotationXY`, the model will be use default rotation values and
    /// will run the attract loop animation. If a value is specified for `rotationXY`, the
    /// model will use the specified rotation values and will not run the attract loop. Response
    /// to drag gestures is not affected by `rotationXY`.
    ///
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    ///     - rotationXY: The rotation, from 0.0 to 1.0, of the model on the X and Y axes.
    public static func compactDisc(
        _ albumArtURL: URL?,
        _ coverColor: UIColor? = nil,
        scale: Float = 1.0,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactDisc3DModelView(albumArtURL, coverColor, scale, rotationXY)
    }
    
    /// Creates a view of an optionally animated 3D model of a compact cassette inside of its case.
    ///
    /// The model's attract loop animation is controlled by the `rotationXY` parameter. If no
    /// value is specified for `rotationXY`, the model will be use default rotation values and
    /// will run the attract loop animation. If a value is specified for `rotationXY`, the
    /// model will use the specified rotation values and will not run the attract loop. Response
    /// to drag gestures is not affected by `rotationXY`.
    ///
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - cassetteColor: The approximate color of the cassette, including opacity.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    ///     - rotationXY: The rotation, from 0.0 to 1.0, of the model on the X and Y axes.
    public static func compactCassette(
        _ albumArtURL: URL?,
        _ cassetteColor: UIColor,
        _ coverColor: UIColor? = nil,
        scale: Float = 2.0,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactCassette3DModelView(albumArtURL, cassetteColor, coverColor, scale, rotationXY)
    }
    
    // MARK: Thumbnail Views -
    
    /// Creates a view of a thumbnail image displaying a 3D model of a vinyl record partially
    /// pulled from its sleeve.
    ///
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - vinylColor: The approximate color of the vinyl, including opacity.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    ///     - rotationXY: The rotation, from 0.0 to 1.0, of the model on the X and Y axes.
    public static func vinylRecordThumbnail(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        _ coverColor: UIColor? = nil,
        scale: Float = defaultVinylRecordThumbnailScale,
        rotationXY: (Float, Float)? = (0, 0)
    ) -> some View {
        VinylRecordThumbnailView(artworkURL, vinylColor, coverColor, scale, rotationXY)
    }
    
    /// Creates a view of a thumbnail image displaying a 3D model of a compact disc inside of its
    /// partially open case.
    ///
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    ///     - rotationXY: The rotation, from 0.0 to 1.0, of the model on the X and Y axes.
    public static func compactDiscThumbnail(
        _ artworkURL: URL?,
        _ coverColor: UIColor? = nil,
        scale: Float = defaultCompactDiscThumbnailScale,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactDiscThumbnailView(artworkURL, coverColor, scale, rotationXY)
    }
    
    /// Creates a view of a thumbnail image displaying a 3D model of a compact cassette inside of
    /// its case.
    ///
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - cassetteColor: The approximate color of the cassette, including opacity.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    ///     - rotationXY: The rotation, from 0.0 to 1.0, of the model on the X and Y axes.
    public static func compactCassetteThumbnail(
        _ artworkURL: URL?,
        _ cassetteColor: UIColor,
        _ coverColor: UIColor? = nil,
        scale: Float = defaultCompactCassetteThumbnailScale,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactCassetteThumbnailView(artworkURL, cassetteColor, coverColor, scale, rotationXY)
    }
    
    // MARK: Thumbnail Images -
    
    public static func vinylRecordThumbnailImage(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        coverColor: UIColor? = nil,
        scale: Float = defaultVinylRecordThumbnailScale,
        rotationXY: (Float, Float)? = (0, 0)
    ) async -> UIImage? {
        return await thumbnailImage(
            for: .vinylRecord,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: vinylColor,
            scale: scale,
            rotationXY: rotationXY
        )
    }
    
    public static func compactDiscThumbnailImage(
        _ artworkURL: URL?,
        coverColor: UIColor? = nil,
        scale: Float = defaultCompactDiscThumbnailScale,
        rotationXY: (Float, Float)? = nil
    ) async -> UIImage? {
        return await thumbnailImage(
            for: .compactDisc,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: nil,
            scale: scale,
            rotationXY: rotationXY
        )
    }
    
    public static func compactCassetteThumbnailImage(
        _ artworkURL: URL?,
        _ cassetteColor: UIColor,
        coverColor: UIColor? = nil,
        scale: Float = defaultCompactCassetteThumbnailScale,
        rotationXY: (Float, Float)? = nil
    ) async -> UIImage? {
        return await thumbnailImage(
            for: .compactCassette,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: cassetteColor,
            scale: scale,
            rotationXY: rotationXY
        )
    }
    
    public static func thumbnailImage(
        for mediaType: MediaType,
        artworkURL: URL?,
        coverColor: UIColor? = nil,
        mediaColor: UIColor?,
        scale: Float? = nil,
        rotationXY: (Float, Float)? = nil
    ) async -> UIImage? {
        let thumbnailScale: Float = scale ?? {
            switch mediaType {
            case .vinylRecord:
                defaultVinylRecordThumbnailScale
            case .compactDisc:
                defaultCompactDiscThumbnailScale
            case .compactCassette:
                defaultCompactCassetteThumbnailScale
            }
        }()
        
        let key = cacheKey(
            for: mediaType,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: mediaColor,
            scale: thumbnailScale,
            rotationXY: rotationXY,
        )
        
        if let thumbnail = await ThumbnailCache.shared.retrieveThumbnail(with: key) {
            return thumbnail
        } else {
            do {
                Log.general.debug("PhysicalMedia.thumbnailImage(...) - Loading entity...")
                let model: PhysicalMediaModel = {
                    switch mediaType {
                    case .vinylRecord:
                        VinylRecordModel()
                    case .compactDisc:
                        CompactDiscModel()
                    case .compactCassette:
                        CompactCassetteModel()
                    }
                }()
                
                let entity = try await model.loadEntity(
                    with: artworkURL,
                    coverColor: coverColor,
                    mediaColor: mediaColor,
                    scale: thumbnailScale
                )
                
                return await ThumbnailRenderer.shared.thumbnail(
                    for: entity,
                    with: key,
                    and: rotationXY,
                )
            } catch {
                Log.general.error(
                """
                PhysicalMedia.thumbnailImage(...) - Error while loading model: \
                \(error.localizedDescription)
                """
                )
                return nil
            }
        }
    }
    
    public static func configureThumbnailCache(with diskCacheURL: URL) {
        ThumbnailCache.configure(with: diskCacheURL)
    }
    
    nonisolated public static func cachedThumbnail(for key: String) -> UIImage? {
        return ThumbnailCache.thumbnailFromDisk(for: key)
    }
    
    nonisolated public static func cacheKey(
        for mediaType: MediaType,
        artworkURL: URL?,
        coverColor: UIColor?,
        mediaColor: UIColor?,
        scale: Float,
        rotationXY: (Float, Float)?,
    ) -> String {
        return ThumbnailCache.cacheKey(
            for: mediaType,
            artworkURL: artworkURL,
            coverColor: coverColor,
            mediaColor: mediaColor,
            scale: scale,
            rotationXY: rotationXY
        )
    }
    
    nonisolated public static func albumArtwork(from url: URL) async -> CGImage? {
        return await ArtworkCache.shared.loadImage(from: url)
    }
}
