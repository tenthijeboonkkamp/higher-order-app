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

public typealias Application = HigherOrderApp<Input, Output>

extension Application {
    public static let `default`:Self = Application(
        input: { Input.init() },
        output: Output.init,
        reducer: { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                print("case .appDelegate(.didFinishLaunching):")
                return .none
            default:
                return .none
            }
        },
        collection: .init(
            reducer: { state, action in
                print(Date().formatted(date: .abbreviated, time: .standard))
                return .none
            },
            searchable: .init { string, element in
                string.isEmpty ? true : element.input.string.lowercased().contains(string.lowercased())
            }
        )
    )
}






