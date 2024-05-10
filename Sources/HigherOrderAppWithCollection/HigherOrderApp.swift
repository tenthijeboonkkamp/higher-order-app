//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit
import CollectionFeature
import ElementFeature
import HigherOrderApp



@Reducer
public struct HigherOrderAppWithCollection<
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
> : Sendable{
    public let higherOrder: HigherOrderApp<HigherOrderAppWithCollection<Input, Output>.Destination>
    public let input: @Sendable () -> Input
    public let output: @Sendable (Input) async throws -> Output
    public let reducer: @Sendable (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
    public let searchable: CollectionFeature<Input, Output>.Searchable?
    
    public init(
        input: @Sendable @escaping () -> Input,
        output: @Sendable @escaping (Input) async throws -> Output,
        reducer:  @Sendable @escaping (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action> = {_, _ in .none },
        searchable: CollectionFeature<Input, Output>.Searchable? = nil
    ) {
        self.higherOrder = .init(
            destination: {
                .init(
                    input: input,
                    output: output,
                    reducer: reducer,
                    searchable: searchable
                )
            }
        )
        self.input = input
        self.output = output
        self.reducer = reducer
        self.searchable = searchable
    }
    
    @ObservableState
    public struct State {
        public var higherOrder: HigherOrderApp<HigherOrderAppWithCollection<Input, Output>.Destination>.State
        @Shared public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>

//        public init(
//            higherOrder: HigherOrderApp<HigherOrderAppWithCollection<Input, Output>.Destination>.State,
//            elements: Shared<IdentifiedArrayOf<ElementFeature<Input, Output>.State>>
//        ) {
//            self.higherOrder = higherOrder
//            self._elements = elements
//        }
        
        public init(
            tint: Shared<Color?> = .init(nil),
            elements: Shared<IdentifiedArrayOf<ElementFeature<Input, Output>.State>>,
            destination: CollectionFeature<Input, Output>.Destination.State? = nil
        ) {
            self.higherOrder = .init(
                tint: tint,
                destination: .collectionFeature(.init(elements: elements, destination: destination))
            )
            self._elements = elements
        }
        
    }
    
    @CasePathable
    @dynamicMemberLookup
    public enum Action: Sendable, BindableAction {
        case higherOrder(HigherOrderApp<HigherOrderAppWithCollection<Input, Output>.Destination>.Action)
        case setOutput(Output)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            
        Scope(state: \.higherOrder, action: \.higherOrder) {
            HigherOrderApp<HigherOrderAppWithCollection<Input, Output>.Destination>.init(
                destination: self.higherOrder.destination,
                reducer: self.higherOrder.reducer
            )
        }
        
        Reduce { state, action in
            
            switch action {
            case let .higherOrder(.destination(.presented(.collectionFeature(.destination(.presented(.element(.delegate(delegate)))))))):
                switch delegate {
                case let .onAppear(input):
                    return .run { [element = state.higherOrder.destination?.collectionFeature?.destination?.element] send in
                        if let element, element.output == nil {
                            try await send(.setOutput(output(input)))
                        }
                    }
                    
                case let .inputUpdated(input):
                    print("aedsbfaslf")
                    return .run { send in
                        try await send(.setOutput(output(input)))
                    }
                    .throttle(id: ThrottleID.inputUpdated, for: .milliseconds(300), scheduler: mainQueue, latest: true)
                }
                
            case let .setOutput(output):
                print("23456789")
                state.higherOrder.destination?.collectionFeature?.destination?.element?.output = output
                return .none
                
                
            default:
                return .none
            }
        }
    }
}

extension HigherOrderAppWithCollection {
    @Reducer
    public struct Destination {
        public let input: @Sendable ()->Input
        public let output: @Sendable (Input) async throws -> Output
        public let reducer: @Sendable (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
        public let searchable: CollectionFeature<Input, Output>.Searchable?
        
        public init(
            input: @Sendable @escaping () -> Input,
            output: @Sendable @escaping (Input) async throws -> Output,
            reducer: @Sendable @escaping (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>,
            searchable: CollectionFeature<Input, Output>.Searchable?
        ) {
            self.input = input
            self.output = output
            self.reducer = reducer
            self.searchable = searchable
        }
        
        @CasePathable
        @dynamicMemberLookup
        @ObservableState
        public enum State: Equatable {
            case collectionFeature(CollectionFeature<Input, Output>.State)
        }
        
        @CasePathable
        @dynamicMemberLookup
        public enum Action: Sendable {
            case collectionFeature(CollectionFeature<Input, Output>.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.collectionFeature, action: \.collectionFeature) {
                CollectionFeature<Input, Output>(
                    input: self.input,
                    output: self.output,
                    reducer: self.reducer,
                    searchable: self.searchable
                )
            }
        }
    }
}

fileprivate enum ThrottleID { case inputUpdated }
