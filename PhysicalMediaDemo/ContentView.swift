//
//  ContentView.swift
//  PhysicalMediaDemo
//
//  Created by Spencer Hartland on 6/12/25.
//

import SwiftUI
import PhysicalMediaKit

struct ContentView: View {
    private let demoAlbumArtURLString = "https://media.pitchfork.com/photos/5f63d96c291a3fedd683eb5d/master/pass/&&&&&_arca.jpg"
    
    var body: some View {
        if let albumArtURL = URL(string: demoAlbumArtURLString) {
            VStack {
                PhysicalMedia.compactDisc(
                    albumArtURL: albumArtURL,
                    scale: 0.6
                )
                
                Text("cd.usdz")
            }
            
        } else {
            Text(":(\nAn error occurred while loading the Album Art.")
        }
    }
}

#Preview {
    ContentView()
}
