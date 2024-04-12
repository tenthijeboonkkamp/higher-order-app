//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 14-03-2024.
//

import Foundation
import SwiftUI

public struct ResultLabel:SwiftUI.View {
    public enum Variant {
        case success
        case failure
    }
    
    let variant: Variant
    let text:Text
    let image:Image
    
    var color:Color {
        switch variant {
        case .success:
                .green
        case .failure:
                .red
        }
    }
            
    
    public var body: some SwiftUI.View {
        Label {
            text
        } icon: {
            image
                .foregroundStyle(color)
        }

    }
    
    public init(
        _ variant:Variant,
        text: ()->SwiftUI.Text
    ){
        var systemName = switch variant {
        case .success:
            "checkmark.circle.fill"
        case .failure:
            "xmark.circle.fill"
        }

        self.image = Image(systemName: systemName)
        self.text = text()
        self.variant = variant
        
    }
}
