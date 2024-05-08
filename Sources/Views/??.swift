//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 08-05-2024.
//

import Foundation
import SwiftUI

infix operator ?? : NilCoalescingPrecedence

public func ??<T>(binding: Binding<T?>, defaultValue: T) -> Binding<T> {
    Binding<T>(
        get: {
            binding.wrappedValue ?? defaultValue
        },
        set: {
            binding.wrappedValue = $0
        }
    )
}
