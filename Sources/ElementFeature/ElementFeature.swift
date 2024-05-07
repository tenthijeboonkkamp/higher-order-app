//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import MemberwiseInit

@Reducer
public struct ElementFeature<
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
>: Sendable {
    
    
    public let reducer: @Sendable (State, Action) -> Effect<Action>
    
    public init(reducer: @Sendable @escaping (State, Action) -> Effect<Action> = {_, _ in .none} ) {
        self.reducer = reducer
    }
    
    @ObservableState
    @dynamicMemberLookup
    public struct State: Codable, Hashable, Identifiable, Sendable {
        @Init(default: UUID())
        public let id: UUID
        public var input:Input
        public var output:Output? = nil
        
        public init(
            id: UUID = UUID(),
            input: Input,
            output:Output?
        ) {
            self.id = id
            self.input = input
            self.output = output
        }
        
        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Input, T>) -> T {
            input[keyPath: keyPath]
        }
        
        public subscript<T>(dynamicMember keyPath: KeyPath<Output?, T>) -> T? {
            output?[keyPath: keyPath]
        }
        
        public subscript<T>(dynamicMember keyPath: KeyPath<Output?, T?>) -> T? {
            output?[keyPath: keyPath]
        }
        
        public subscript<T>(dynamicMember keyPath: KeyPath<Output, T?>) -> T? {
            output?[keyPath: keyPath]
        }
    }
    
    public enum Action: Sendable, BindableAction {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        
        @CasePathable
        public enum Delegate: Sendable {
            case onAppear(Input)
            case inputUpdated(Input)
        }
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.input) { oldValue, newValue in
                Reduce { state, action in
                        .send(.delegate(.inputUpdated(newValue)))
                }
            }
        
        Reduce { state, action in
            reducer(state, action)
        }
    }
}

extension ElementFeature {
    public struct LabelView<
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<ElementFeature<Input, Output>>
        public let navigationLinkLabel: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        
        @SwiftUI.State var sheet: Bool = false
        
        public init(
            store: StoreOf<ElementFeature<Input, Output>>,
            navigationLinkLabel: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView
        ) {
            self.store = store
            self.navigationLinkLabel = navigationLinkLabel
        }
        
        public var body: some SwiftUI.View {
            self.navigationLinkLabel($store)
        }
    }
    
    public struct DestinationView<
        NavigationLinkDestinationView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<ElementFeature<Input, Output>>
        public let navigationLinkDestination: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        
        @SwiftUI.State var sheet: Bool = false
        
        public init(
            store: StoreOf<ElementFeature<Input, Output>>,
            navigationLinkDestination: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            self.navigationLinkDestination($store)
        }
    }
}
