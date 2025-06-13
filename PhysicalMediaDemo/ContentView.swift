//
//  ContentView.swift
//  PhysicalMediaDemo
//
//  Created by Spencer Hartland on 6/12/25.
//

import SwiftUI
import PhysicalMediaKit

fileprivate enum MediaType {
    case vinylRecord
    case compactDisc
    case compactCassette
}

struct ContentView: View {
    @State private var albumArtURLString = "https://media.pitchfork.com/photos/5f63d96c291a3fedd683eb5d/master/pass/&&&&&_arca.jpg"
    @State private var selectedMediaType: MediaType = .vinylRecord
    @State private var mediaColor: Color = .black
    @State private var mediaOpacity: Float = 1.0
    @State private var modelScale: Float = 0.5
    @State private var modelRequiresReload = false
    
    var body: some View {
        VStack {
            Text("PhysicalMediaKit Demo")
                .font(.body.bold())
            
            Picker("Media Type", selection: $selectedMediaType) {
                Text("Vinyl Record").tag(MediaType.vinylRecord)
                Text("Compact Disc").tag(MediaType.compactDisc)
                Text("Compact Cassette").tag(MediaType.compactCassette)
            }
            .pickerStyle(.segmented)
            
            if let albumArtURL = URL(string: albumArtURLString),
               modelRequiresReload != true {
                switch self.selectedMediaType {
                case .vinylRecord:
                    PhysicalMedia.vinylRecord(
                        albumArtURL: albumArtURL,
                        vinylColor: mediaColor,
                        vinylOpacity: mediaOpacity,
                        scale: modelScale
                    )
                case .compactDisc:
                    PhysicalMedia.compactDisc(
                        albumArtURL: albumArtURL,
                        scale: modelScale
                    )
                case .compactCassette:
                    PhysicalMedia.compactCassette(
                        albumArtURL: albumArtURL,
                        cassetteColor: mediaColor,
                        cassetteOpacity: mediaOpacity,
                        scale: modelScale
                    )
                }
            } else {
                Spacer()
                Label("Loading model...", systemImage: "progress.indicator")
                    .symbolEffect(.variableColor.iterative)
                Spacer()
            }
            
            VStack {
                VStack(alignment: .leading) {
                    Label("Album Artwork URL", systemImage: "globe")
                        .font(.caption.bold())
                    TextField("Album Artwork URL", text: $albumArtURLString, prompt: Text("https:/example.com/artwork"))
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.systemFill))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                
                if selectedMediaType != .compactDisc {
                    ColorPicker("Media Color", selection: $mediaColor)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .font(.caption.bold())
                    
                    VStack(alignment: .leading) {
                        Text("Media Opacity")
                            .font(.caption.bold())
                        Slider(value: $mediaOpacity, in: 0.0...1.0)
                    }
                    .padding([.top, .horizontal])
                    .padding(.bottom, 6)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text("Model Scale")
                        .font(.caption.bold())
                    Slider(value: $modelScale, in: 0.0...1.0)
                }
                .padding([.top, .horizontal])
                .padding(.bottom, 6)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
        .padding()
        .onChange(of: albumArtURLString) { _, _ in
            modelRequiresReload = true
        }
        .onChange(of: mediaColor) { _, _ in
            modelRequiresReload = true
        }
        .onChange(of: mediaOpacity) { _, _ in
            modelRequiresReload = true
        }
        .onChange(of: modelScale) { _, _ in
            modelRequiresReload = true
        }
        .onChange(of: modelRequiresReload) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                modelRequiresReload = false
            }
        }
    }
}

#Preview {
    ContentView()
}
