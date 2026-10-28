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
        scale: Float = 1.0,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        VinylRecord3DModelView(artworkURL, vinylColor, scale, rotationXY)
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
        scale: Float = 1.0,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactDisc3DModelView(albumArtURL, scale, rotationXY)
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
        scale: Float = 2.0,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactCassette3DModelView(albumArtURL, cassetteColor, scale, rotationXY)
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
        scale: Float = 0.125,
        rotationXY: (Float, Float)? = (0.0, -0.08)
    ) -> some View {
        VinylRecordThumbnailView(artworkURL, vinylColor, scale, rotationXY)
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
        scale: Float = 0.125,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactDiscThumbnailView(artworkURL, scale, rotationXY)
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
        scale: Float = 0.250,
        rotationXY: (Float, Float)? = nil
    ) -> some View {
        CompactCassetteThumbnailView(artworkURL, cassetteColor, scale, rotationXY)
    }
    
    // MARK: Thumbnail Images -
    
    public static func configureThumbnailCache(with diskCacheURL: URL) {
        ThumbnailCache.configure(with: diskCacheURL)
    }
    
    public static func vinylRecordThumbnailImage(
        _ artworkURL: URL?,
        _ vinylColor: UIColor,
        scale: Float = 0.125,
        rotationXY: (Float, Float)? = (0.0, -0.08)
    ) async -> UIImage? {
        let model = VinylRecordModel()
        
        guard let entity = await model.loadModel(
            with: artworkURL,
            and: vinylColor,
            at: scale
        ) else {
            return nil
        }
        
        let cacheKey = cacheKey(
            for: .vinylRecord,
            artworkURL: artworkURL,
            mediaColor: vinylColor,
            scale: scale,
            rotationXY: rotationXY,
        )
        
        return await ThumbnailRenderer.shared.thumbnail(
            for: entity,
            with: cacheKey,
            and: rotationXY,
        )
    }
    
    public static func compactDiscThumbnailImage(
        _ artworkURL: URL?,
        scale: Float = 0.125,
        rotationXY: (Float, Float)? = nil
    ) async -> UIImage? {
        let model = CompactDiscModel()
        
        guard let entity = await model.loadModel(
            with: artworkURL,
            at: scale)
        else {
            return nil
        }
        
        let cacheKey = cacheKey(
            for: .compactDisc,
            artworkURL: artworkURL,
            mediaColor: nil,
            scale: scale,
            rotationXY: rotationXY,
        )
        
        return await ThumbnailRenderer.shared.thumbnail(
            for: entity,
            with: cacheKey,
            and: rotationXY,
        )
    }
    
    public static func compactCassetteThumbnailImage(
        _ artworkURL: URL?,
        _ cassetteColor: UIColor,
        scale: Float = 0.250,
        rotationXY: (Float, Float)? = nil
    ) async -> UIImage? {
        let model = CompactCassetteModel()
        
        guard let entity = await model.loadModel(
            with: artworkURL,
            and: cassetteColor,
            at: scale)
        else {
            return nil
        }
        
        let cacheKey = cacheKey(
            for: .compactCassette,
            artworkURL: artworkURL,
            mediaColor: cassetteColor,
            scale: scale,
            rotationXY: rotationXY,
        )
        
        return await ThumbnailRenderer.shared.thumbnail(
            for: entity,
            with: cacheKey,
            and: rotationXY,
        )
    }
    
    public static func thumbnailImage(
        for mediaType: MediaType,
        artworkURL: URL?,
        mediaColor: UIColor?,
        scale: Float,
        rotationXY: (Float, Float)?
    ) async -> UIImage? {
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
        
        guard let entity = await model.loadModel(
            with: artworkURL,
            and: mediaColor,
            at: scale
        ) else {
            return nil
        }
        
        let cacheKey = cacheKey(
            for: mediaType,
            artworkURL: artworkURL,
            mediaColor: mediaColor,
            scale: scale,
            rotationXY: rotationXY,
        )
        
        return await ThumbnailRenderer.shared.thumbnail(
            for: entity,
            with: cacheKey,
            and: rotationXY,
        )
    }
    
    nonisolated public static func cachedThumbnail(for key: String) -> UIImage? {
        return ThumbnailCache.thumbnailFromDisk(for: key)
    }
    
    nonisolated public static func cacheKey(
        for mediaType: MediaType,
        artworkURL: URL?,
        mediaColor: UIColor?,
        scale: Float,
        rotationXY: (Float, Float)?,
    ) -> String {
        let mediaTypeString: String = mediaType.rawValue
        let urlString: String = artworkURL?.absoluteString ?? "no_artwork"
        let colorString: String? = mediaColor?.description
        let scaleString: String = String(scale)
        let rotationXYString: String? = {
            if let rotationXY {
                return "\(rotationXY.0)_\(rotationXY.1)"
            } else {
                return nil
            }
        }()
        
        let components: [String?] = [
            mediaTypeString,
            urlString,
            colorString,
            scaleString,
            rotationXYString,
        ]
        
        var key: String = ""
        for component in components {
            if let component { key.append(component) }
        }
        key = hashString(for: key)
        return key
    }
}

extension PhysicalMedia {
    nonisolated private static func hashString(for string: String) -> String {
        let stringData = Data(string.utf8)
        let hash = SHA256.hash(data: stringData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
