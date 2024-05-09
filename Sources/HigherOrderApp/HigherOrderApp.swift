//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit
import Combine

@Reducer
public struct HigherOrderApp<
    Destination: Reducer
> : Sendable where Destination.Action: CasePathable, Destination.State: Equatable {
    
    public let destination: @Sendable ()-> Destination
    public let reducer: (@Sendable (inout State, Action) -> Effect<Action>)?
    
    public init(
        destination: @Sendable @escaping ()-> Destination,
        reducer:  (@Sendable (inout State, Action) -> Effect<Action>)? = nil
    ) {
        self.reducer = reducer
        self.destination = destination
    }
    
    @ObservableState
    public struct State: Equatable {
        public var appDelegate: HigherOrderApp.Delegate.State
        @Shared public var tint: Color?
        @Presents public var destination: Destination.State?

        public init(
            tint: Shared<Color?>,
            appDelegate: HigherOrderApp.Delegate.State = HigherOrderApp.Delegate.State(),
            destination: Destination.State
        ) {
            self._tint = tint
            self.appDelegate = appDelegate
            self.destination = destination
        }
    }
    
    @CasePathable
    @dynamicMemberLookup
    public enum Action: Sendable, BindableAction {
        case appDelegate(HigherOrderApp.Delegate.Action)
        case didChange(DidChange)
        case destination(PresentationAction<Destination.Action>)
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
        .ifLet(\.$destination, action: \.destination) {
            self.destination()
        }
    }
}

//extension HigherOrderApp {
//    @Reducer
//    public struct Destination {
//        public let input: @Sendable ()->Input
//        public let output: @Sendable (Input) async throws -> Output
////        public let collection: HigherOrderApp.Collection
////        public let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
////        public let searchable: CollectionFeature<Input, Output>.Searchable?
//        
//        @CasePathable
//        @dynamicMemberLookup
//        @ObservableState
//        public enum State {
//            case collectionFeature(CollectionFeature<Input, Output>.State)
//        }
//        
//        @CasePathable
//        @dynamicMemberLookup
//        public enum Action: Sendable {
//            case collectionFeature(CollectionFeature<Input, Output>.Action)
//        }
//        
//        public var body: some ReducerOf<Self> {
//            Scope(state: \.collectionFeature, action: \.collectionFeature) {
//                CollectionFeature<Input, Output>(
//                    input: input,
//                    output: output,
//                    reducer: self.collection.reducer,
//                    searchable: self.collection.searchable
//                )
//            }
//        }
//    }
//}


fileprivate enum ThrottleID { case inputUpdated }

