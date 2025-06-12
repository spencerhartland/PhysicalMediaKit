//
//  PhysicalMediaKit.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 5/7/25.
//

import SwiftUI

/// Provides methods to render customizable, animated 3D models of common physical media (vinyl record, CD, etc.).
public struct PhysicalMedia {
    // TODO: Convert to function that accepts albumArt and vinylColor as parameters.
    /// A view displaying an animated 3D model of a vinyl record partially pulled from its sleeve.
    public static var vinylRecord: some View { VinylRecord3DModelView() }
    
    // TODO: Convert to function that accepts albumArt as a parameter.
    /// A view displaying an animated 3D model of a compact disc inside of its partially open case.
    public static var compactDisc: some View { CompactDisc3DModelView() }
    
    // TODO: Convert to function that accepts albumArt and cassetteColor as parameters.
    /// A view displaying an animated 3D model of a compact cassette inside of its case.
    public static var compactCassette: some View { CompactCassette3DModelView() }
}
