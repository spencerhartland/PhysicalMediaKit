//
//  CoverPlaceholderView.swift
//  PhysicalMediaKit
//
//  Created by Spencer Hartland on 11/7/26.
//

import SwiftUI

struct CoverPlaceholderView: View {
    private static let bgColor = Color(uiColor: .systemBackground)
    
    let color: Color
    
    init(color uiColor: UIColor?) {
        self.color = Color(uiColor: uiColor ?? .secondarySystemBackground)
    }
    
    var body: some View {
        LinearGradient(
            colors: [Self.bgColor, color],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    CoverPlaceholderView(color: .green)
}
