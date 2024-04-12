//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 12-04-2024.
//

import Foundation
import SwiftUI
import MemberwiseInit

extension [Source] {
    public struct View:SwiftUI.View {
        public let sources:[Source]
        
        public init(sources: [Source]) {
            self.sources = sources
        }
        
        public var body: some SwiftUI.View {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sources")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    
                    ForEach(sources, id: \.self) { source in
                        source
                    }
                }
            }
        }
    }
}
