//
//  PlaceholderView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 1/16/26.
//

import SwiftUI

internal struct PlaceholderView: View {
    private let placeholderSymbolName = "music.note"
    
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundStyle(.clear)
                .overlay {
                    Image(systemName: placeholderSymbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(geometry.size.width / 6)
                        .foregroundStyle(.secondary)
                        .symbolEffect(.pulse)
                }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
