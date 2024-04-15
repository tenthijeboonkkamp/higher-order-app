//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import Foundation
import ComposableArchitecture


extension HigherOrderApp {
    @Reducer
    public struct Delegate {
        public struct State: Equatable {
            public init() {}
        }
        
        public enum Action: Sendable {
            case didFinishLaunching
            case applicationWillTerminate
        }
        
        public var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
}
