//
//  MediaType.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 5/26/26.
//

public enum MediaType: String, Codable, CaseIterable, Identifiable, Equatable {
    public var id: Self {
        return self
    }
    case vinylRecord = "Vinyl Record"
    case compactDisc = "Compact Disc"
    case compactCassette = "Compact Cassette"
}
