//
//  PhysicalMediaKit.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 5/7/25.
//

import SwiftUI

/// Provides methods to render customizable, animated 3D models of common physical media (vinyl record, CD, etc.).
public struct PhysicalMedia {
    // TODO: Add scale parameter.
    /// Creates a view displaying an animated 3D model of a vinyl record partially pulled from its sleeve.
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - vinylColor: The approximate color of the vinyl.
    ///     - vinylOpacity: The opacity of the vinyl.
    public static func vinylRecord(albumArtURL: URL, vinylColor: Color, vinylOpacity: Float) -> some View {
        VinylRecord3DModelView(albumArtURL, vinylColor, vinylOpacity)
    }
    
    /// Creates a view displaying an animated 3D model of a compact disc inside of its partially open case.
    /// - Parameters:
    ///     - albumArtURL: The remote URL from which to retrieve album artwork.
    ///     - scale: The scale, from 0.0 to 1.0, at which to display the model.
    public static func compactDisc(albumArtURL: URL, scale: Float = 1.0) -> some View {
        CompactDisc3DModelView(albumArtURL, scale)
    }
    
    // TODO: Convert to function that accepts albumArt and cassetteColor as parameters.
    /// A view displaying an animated 3D model of a compact cassette inside of its case.
    public static var compactCassette: some View { CompactCassette3DModelView() }
}
