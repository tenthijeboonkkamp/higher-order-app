//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 09-04-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import HigherOrderApp
import Output

public typealias ExampleApplication = HigherOrderApp<Input, Output>

extension ExampleApplication {
    public static let `default`:Self = ExampleApplication(
        input: { Input() },
        output: Output.init
    )
}
extension ExampleApplication {
    public static func `default`(store: StoreOf<ExampleApplication>) -> some SwiftUI.View {
        return ExampleApplication.View(
            store: store,
            navigationLinkLabel: { $store in
                SwiftUI.Text("\(!store.string.isEmpty ? store.string : "empty")")
            },
            navigationLinkDestination: { $store in
                Form {
                    TextField("string", text: $store.input.string)
                    Bool?.View(
                        question: "question?",
                        answer: $store.input.bool
                    )
                }
            }
        )
    }
}
