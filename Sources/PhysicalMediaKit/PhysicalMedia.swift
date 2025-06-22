//
//  PhysicalMedia.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 5/7/25.
//

import SwiftUI

/// Provides methods to render customizable, animated 3D models of common physical media (vinyl record, CD, etc.).
@MainActor
public struct PhysicalMedia {
    /// Creates a view displaying an animated 3D model of a vinyl record partially pulled from its sleeve.
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - vinylColor: The approximate color of the vinyl, including opacity.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    public static func vinylRecord(
        albumArtURL: URL,
        vinylColor: Color,
        scale: Float = 1.0
    ) -> some View {
        VinylRecord3DModelView(albumArtURL, vinylColor, scale)
    }
    
    /// Creates a view displaying an animated 3D model of a compact disc inside of its partially open case.
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    public static func compactDisc(
        albumArtURL: URL,
        scale: Float = 1.0
    ) -> some View {
        CompactDisc3DModelView(albumArtURL, scale)
    }
    
    /// Creates a view displaying an animated 3D model of a compact cassette inside of its case.
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - cassetteColor: The approximate color of the cassette, including opacity.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    public static func compactCassette(
        albumArtURL: URL,
        cassetteColor: Color,
        scale: Float = 1.0
    ) -> some View {
        CompactCassette3DModelView(albumArtURL, cassetteColor, scale)
    }
}
