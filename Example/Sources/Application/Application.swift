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

extension Application {
    public static var `default`:Self = Application.init(
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






