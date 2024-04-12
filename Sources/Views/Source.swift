//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 12-04-2024.
//

import Foundation
import SwiftUI
import MemberwiseInit

public struct Source: SwiftUI.View, Hashable {
    public let title: String
    public let source: String
    
    public init(title: String, source: String) {
        self.title = title
        self.source = source
    }
    
    public var body: some SwiftUI.View {
        Card {
            Text(title)
                .font(.subheadline)
            Text(source)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
