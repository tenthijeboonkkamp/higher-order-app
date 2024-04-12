//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 12-04-2024.
//

import Foundation
import SwiftUI
import MemberwiseInit

public struct Card<Content: SwiftUI.View>: SwiftUI.View {
    
    let variant:Variant
    let content: ()-> Content
    
    public enum Variant {
        case systemGroupedBackground
        case shadow
    }
    
    public init(
        _ variant: Variant = .systemGroupedBackground,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.variant = variant
        self.content = content
    }
    
    var background: Color {
        switch variant {
        case .systemGroupedBackground:
            return Color(.systemGroupedBackground)
        case .shadow:
            return .clear
        }
    }
    
    public var body: some SwiftUI.View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(background)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        
        .cornerRadius(8)
    }
}
