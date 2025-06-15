//
//  PhysicalMediaKitDemoView.swift
//  PhysicalMediaKitDemo
//
//  Created by Spencer Hartland on 6/12/25.
//

import SwiftUI
import PhysicalMediaKit

fileprivate enum MediaType: String {
    case vinylRecord = "Vinyl Record"
    case compactDisc = "Compact Disc"
    case compactCassette = "Compact Cassette"
}

struct PhysicalMediaKitDemoView: View {
    private let viewTitle = "PhysicalMediaKit Demo"
    private let mediaTypePickerTitle = "Media Type"
    private let modelReloadLabelText = "Loading model..."
    private let modelReloadSymbolName = "progress.indicator"
    private let albumArtworkURLLabelText = "Album Artwork URL"
    private let albumArtworkURLPromptText = "https:/example.com/artwork"
    private let albumArtworkURLSymbolName = "globe"
    private let mediaColorLabelText = "Media Color"
    private let mediaOpacityLabelText = "Media Opacity"
    private let modelScaleLabelText = "Model Scale"
    
    @State private var albumArtURLString = "https://www.rollingstone.com/wp-content/uploads/2025/06/Addison-Rae_FRONT-COVER-final-crop.jpg?w=1024"
    @State private var selectedMediaType: MediaType = .vinylRecord
    @State private var mediaColor: Color = .pink
    @State private var mediaOpacity: Float = 0.5
    @State private var modelScale: Float = 0.8
    @State private var modelRequiresReload = false
    
    var body: some View {
        VStack {
            Text(viewTitle)
                .font(.body.bold())
            
            Picker(mediaTypePickerTitle, selection: $selectedMediaType) {
                Text(MediaType.vinylRecord.rawValue).tag(MediaType.vinylRecord)
                Text(MediaType.compactDisc.rawValue).tag(MediaType.compactDisc)
                Text(MediaType.compactCassette.rawValue).tag(MediaType.compactCassette)
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
                Label(modelReloadLabelText, systemImage: modelReloadSymbolName)
                    .symbolEffect(.variableColor.iterative)
                Spacer()
            }
            
            VStack {
                VStack(alignment: .leading) {
                    Label(albumArtworkURLLabelText, systemImage: albumArtworkURLSymbolName)
                        .font(.caption.bold())
                    TextField(albumArtworkURLLabelText, text: $albumArtURLString, prompt: Text(albumArtworkURLPromptText))
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.systemFill))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)
                
                if selectedMediaType != .compactDisc {
                    ColorPicker(mediaColorLabelText, selection: $mediaColor)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .font(.caption.bold())
                    
                    VStack(alignment: .leading) {
                        Text(mediaOpacityLabelText)
                            .font(.caption.bold())
                        Slider(value: $mediaOpacity, in: 0.0...1.0)
                    }
                    .padding([.top, .horizontal])
                    .padding(.bottom, 6)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text(modelScaleLabelText)
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
    PhysicalMediaKitDemoView()
}
