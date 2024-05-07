//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 07-05-2024.
//

import Foundation
import SwiftUI

public struct GenericPicker<
    T: Hashable,
    CaseView: SwiftUI.View,
    LabelView: SwiftUI.View
>: View {
    @Binding var selection: T?
    var cases: [T]
    var `case`: (T) -> CaseView
    var label: () -> LabelView
    
    public var body: some View {
        Picker(
            selection: $selection.animation(),
            content: {
                ForEach(cases, id: \.self) { option in
                    `case`(option)
                        .tag(Optional(option))
                }
            },
            label: label
        )
        .pickerStyle(.segmented)
    }
}
//
//extension Optional:CaseIterable where Wrapped: CaseIterable {
//    public static var allCases: [Optional<Wrapped>] {
//        [nil] + Wrapped.allCases.map(Self.init)
//    }
//}
//
//extension Bool: CaseIterable {
//    public static var allCases: [Bool] {
//        [
//            true, false
//        ]
//    }
//}
