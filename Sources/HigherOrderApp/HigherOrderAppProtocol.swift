//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 10-05-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI

public protocol HigherOrderAppProtocol: Reducer {
    associatedtype Delegate: NSObject, UIApplicationDelegate
    associatedtype View: SwiftUI.View
    associatedtype Input: Codable & Hashable & Sendable
    associatedtype Output: Codable & Hashable & Sendable
    
    static var store: StoreOf<Self> { get }
    
    var input: @Sendable () -> Input { get }
    var output: (
        init: @Sendable () -> Output,
        compute: @Sendable (Input) async throws -> Output
    ) {
        get
    }
}
