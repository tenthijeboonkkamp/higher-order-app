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
        
        public enum Action {
            case didFinishLaunching
        }
        
        public var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .didFinishLaunching:
                    return .none
                }
            }
        }
    }
}