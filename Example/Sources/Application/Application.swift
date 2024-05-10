//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 09-04-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import HigherOrderAppWithCollection
import Output

public typealias Application = HigherOrderAppWithCollection<Input, Output>


extension Application: HigherOrderAppProtocol {
    public static var store: StoreOf<HigherOrderAppWithCollection<Input, Output>> {
        Store(
            initialState: Application.State.init(
                tint: Shared(
                    wrappedValue: Color.green,
                    .fileStorage(.documentsDirectory.appending(path: "color.json"))
                ),
                elements: Shared(
                    wrappedValue: .init(uniqueElements: []),
                    .fileStorage(.documentsDirectory.appending(path: "elements.json"))
                ),
                destination: nil
            ),
            reducer: {
                Application.init(
                    input: { Input.init() },
                    output: Output.init,
                    reducer: { state, action in
                        print(Date().formatted(date: .abbreviated, time: .standard))
                        return .none
                    },
                    searchable: .init { string, element in
                        string.isEmpty ? true : element.string.lowercased().contains(string.lowercased())
                    }
                )
            }
        )
    }
    
    public var output: (
        init: @Sendable () -> Output,
        compute: @Sendable (Input) async throws -> Output
    ) {
        (
            init: { Output.init() },
            compute: Output.init
        )
    }
}





