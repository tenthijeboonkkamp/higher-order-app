//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit

@Reducer
public struct HigherOrderApp<
    Destination: Reducer
> : Sendable where Destination.Action: CasePathable & Sendable, Destination.State: Equatable {
    
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

fileprivate enum ThrottleID { case inputUpdated }

