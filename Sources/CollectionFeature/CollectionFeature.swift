//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import MemberwiseInit
import ElementFeature

@Reducer
public struct CollectionFeature<
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
> {
    
    public let input: @Sendable ()->Input
    public let output: @Sendable (Input) async throws -> Output
    public let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
    
   
    
    public init(
        input: @Sendable @escaping ()->Input,
        output: @Sendable @escaping (Input) async throws -> Output,
        reducer: @Sendable @escaping (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
    ) {
        self.input = input
        self.output = output
        self.reducer = reducer
    }

    @ObservableState
    public struct State {
        @Shared public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>
        @Presents public var destination: CollectionFeature.Destination.State?
        
        public init(
            elements: Shared<IdentifiedArrayOf<ElementFeature<Input, Output>.State>>,
            destination: CollectionFeature.Destination.State? = nil
        ) {
            self._elements = elements
            self.destination = destination
        }
    }
    
    public enum Action: Sendable {
        case elements(IdentifiedActionOf<ElementFeature<Input, Output>>)
        case destination(PresentationAction<CollectionFeature.Destination.Action>)
        case elementButtonTapped(ElementFeature<Input, Output>.State)
        case addElementButtonTapped
        case deleteButtonTapped(id: ElementFeature<Input, Output>.State.ID)
    }
    

    public struct Destination: Reducer {
        
        public let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
        
        public init(
            reducer: @Sendable @escaping (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action> = { _, _ in .none }
        ) {
            self.reducer = reducer
        }
        
        
        @CasePathable
        @dynamicMemberLookup
        @ObservableState
            public enum State {
            case element(ElementFeature<Input, Output>.State)
        }

        @CasePathable
        public enum Action: Sendable {
            case element(ElementFeature<Input, Output> .Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.element, action: \.element) {
                ElementFeature<Input, Output>(reducer: reducer)
            }
        }
    }
    
    public var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
            case let .elementButtonTapped(element):
                state.destination = .element(element)
                return .none
                
            case .addElementButtonTapped:
                let element = ElementFeature<Input, Output>.State.init(input: input(), output: nil)
                let _ = withAnimation {
                    state.elements.append(element)
                }
                state.destination = .init(.element(element))
                return .none
                
            case .destination(.dismiss):
                let input = input()
                withAnimation {
                    state.elements.removeAll { $0.input == input }
                }
                
                if let element = state.destination?.element {
                    state.elements[id: element.id] = element
                }
                
                
                return .none

            case .deleteButtonTapped(id: let id):
                state.elements[id: id] = nil
                return .none
                
            case .elements, .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination(reducer: self.reducer)
        }
    }
    
    public struct View<
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<CollectionFeature>
        public let navigationLinkLabel: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<CollectionFeature>,
            @ViewBuilder navigationLinkLabel: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            List {
//                ForEach(store.$elements.elements) { elementStore in
                ForEach(store.scope(state: \.elements, action: \.elements)) { elementStore in
                    Button {
                        store.send(.elementButtonTapped(elementStore.state))
                    } label: {
                        ElementFeature.LabelView.init(store: elementStore, navigationLinkLabel: navigationLinkLabel)
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive){
                            store.send(.deleteButtonTapped(id:  elementStore.id))
                        } label: {
                            Text("Delete")
                        }
                    }
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.element, action: \.destination.element)
            ) { localStore in
                ElementFeature.DestinationView(
                    store: localStore,
                    navigationLinkDestination: self.navigationLinkDestination
                )
                    .onAppear{
                        localStore.send(.delegate(.onAppear(localStore.input)))
                    }
                    
            }
            .toolbar {
                Button {
                    store.send(.addElementButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }

        }
    }
}

