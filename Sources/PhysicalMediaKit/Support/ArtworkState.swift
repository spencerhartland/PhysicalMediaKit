//
//  ArtworkState.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/18/26.
//

import RealityKit

enum ArtworkState {
    case notRequested
    case loading
    case ready(TextureResource)
    case failedToLoad
}
