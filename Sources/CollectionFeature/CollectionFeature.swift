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
    
    public let input: ()->Input
    public let output: @Sendable (Input) async throws -> Output
    
    public init(
        input: @escaping ()->Input,
        output: @Sendable @escaping (Input) async throws -> Output
    ) {
        self.input = input
        self.output = output
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
    @CasePathable
    @dynamicMemberLookup
    @Reducer(state: .sendable, .equatable)
    public enum Destination {
        case element(ElementFeature<Input, Output>)
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
                return .none
            case .elements, .destination:
                return .none
            case .deleteButtonTapped(id: let id):
                state.elements[id: id] = nil
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.destination?.element) { oldValue, newValue in
            Reduce { state, action in
                guard let id = newValue?.id 
                else { return .none }
                
                state.elements[id: id] = newValue
                return .none
            }
        }
    }
    
    public struct View<
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<CollectionFeature>
        public let navigationLinkLabel: (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<CollectionFeature>,
            @ViewBuilder navigationLinkLabel: @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
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
            .navigationDestination(item: $store.scope(state: \.destination?.element, action: \.destination.element)) { localStore in
                ElementFeature.DestinationView.init(store: localStore, navigationLinkDestination: navigationLinkDestination)
                    .onAppear{
                        localStore.send(.delegate(.onAppear(localStore.id, localStore.input)))
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

