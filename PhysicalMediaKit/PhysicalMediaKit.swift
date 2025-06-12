//
//  PhysicalMediaKit.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 5/7/25.
//

import SwiftUI

public struct PhysicalMedia {
    // TODO: Convert to function that accepts albumArt (url) and vinylColor as parameters.
    /// A view displaying an animated 3D model of a vinyl record partially pulled from its sleeve.
    public static var vinylRecord: some View { VinylRecord3DModelView() }
}
