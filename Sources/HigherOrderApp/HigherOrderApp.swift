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
import Combine

@Reducer
public struct HigherOrderApp<
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
> : Sendable{
    
    public let input: @Sendable () -> Input
    public let output: @Sendable (Input) async throws -> Output
    public let reducer:  (@Sendable (inout State, Action) -> Effect<Action>)?
    public let collection: Collection
    
    public init(
        input: @Sendable @escaping () -> Input,
        output: @Sendable @escaping (Input) async throws -> Output,
        reducer:  (@Sendable (inout State, Action) -> Effect<Action>)? = nil,
        collection: Collection
    ) {
        self.input = input
        self.output = output
        self.reducer = reducer
        self.collection = collection
    }
    
    @ObservableState
    public struct State {
        public var appDelegate: HigherOrderApp.Delegate.State
        @Shared public var tint: Color?
        @Shared public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>
        @Presents public var destination: HigherOrderApp<Input, Output>.Destination.State?

        public init(
            tint: Shared<Color?>,
            appDelegate: HigherOrderApp.Delegate.State = HigherOrderApp.Delegate.State(),
            elements: Shared<IdentifiedArrayOf<ElementFeature<Input, Output>.State>>
        ) {
            self._tint = tint
            self.appDelegate = appDelegate
            self._elements = elements
            self.destination = .collectionFeature(
                .init(
                    elements: elements
                )
            )
        }
    }
    
    @CasePathable
    @dynamicMemberLookup
    public enum Action: Sendable, BindableAction {
        case appDelegate(HigherOrderApp.Delegate.Action)
        case didChange(DidChange)
        case destination(PresentationAction<Destination.Action>)
        case collectionFeature(CollectionFeature<Input, Output>.Action)
        case setOutput(Output)
        case binding(BindingAction<State>)
        
        @CasePathable
        public enum DidChange: Sendable {
            case scenePhase(old: ScenePhase, new: ScenePhase)
        }
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        self.reducer.map(Reduce.init)
        
        Reduce { state, action in
            switch action {
            case let .destination(.presented(.collectionFeature(.destination(.presented(.element(.delegate(delegate))))))):
                switch delegate {
                case let .onAppear(input):
                    return .run { [element = state.destination?.collectionFeature?.destination?.element] send in
                        if let element, element.output == nil {
                            try await send(.setOutput(output(input)))
                        }
                    }
                    
                case let .inputUpdated(input):
                    return .run { send in
                        try await send(.setOutput(output(input)))
                    }
                    .throttle(id: ThrottleID.inputUpdated, for: .milliseconds(300), scheduler: mainQueue, latest: true)
                }
                
            case let .setOutput(output):
                state.destination?.collectionFeature?.destination?.element?.output = output
                return .none
                
            case .appDelegate, .didChange, .collectionFeature:
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            HigherOrderApp<Input, Output>.Destination(
                input: self.input,
                output: self.output,
                collection: collection
            )
        }
    }
}

extension HigherOrderApp {
    public struct Collection: Sendable{
        public let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
        public let searchable: CollectionFeature<Input, Output>.Searchable?
        
        public init(
            reducer: @Sendable @escaping (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>,
            searchable: CollectionFeature<Input, Output>.Searchable?
        ) {
            self.reducer = reducer
            self.searchable = searchable
        }
    }
}

extension HigherOrderApp {
    @Reducer
    public struct Destination {
        public let input: @Sendable ()->Input
        public let output: @Sendable (Input) async throws -> Output
        public let collection: HigherOrderApp.Collection
//        public let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
//        public let searchable: CollectionFeature<Input, Output>.Searchable?
        
        @CasePathable
        @dynamicMemberLookup
        @ObservableState
        public enum State {
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
                    input: input,
                    output: output,
                    reducer: self.collection.reducer,
                    searchable: self.collection.searchable
                )
            }
        }
    }
}


fileprivate enum ThrottleID { case inputUpdated }

