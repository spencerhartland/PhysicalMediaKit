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
        Rectangle()
            .aspectRatio(1, contentMode: .fit)
            .foregroundStyle(.clear)
            .overlay {
                Image(systemName: placeholderSymbolName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .foregroundStyle(.secondary)
                    .symbolEffect(.pulse)
            }
    }
}
