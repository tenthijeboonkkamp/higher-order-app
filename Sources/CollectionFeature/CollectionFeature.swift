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
import Element



@MemberwiseInit(.public)
@Reducer
public struct CollectionFeature<
    Input: Codable & Hashable,
    Output: Codable & Hashable
> {
    
    public let input: ()->Input
    
    @MemberwiseInit(.public)
    @ObservableState
    public struct State {
        @Shared(.fileStorage(.documentsDirectory.appending(path: "elements.json"))) public var elements: IdentifiedArrayOf<Element<Input, Output>.State> = []
        @Presents public var destination: CollectionFeature.Destination.State?
        
        public init(destination: CollectionFeature.Destination.State? = nil) {
            self.destination = destination
        }
    }
    
    public enum Action {
        case elements(IdentifiedActionOf<Element<Input, Output>>)
        case destination(PresentationAction<CollectionFeature.Destination.Action>)
        case elementButtonTapped(Element<Input, Output>.State)
        case addElementButtonTapped
        case deleteButtonTapped(id: Element<Input, Output>.State.ID)
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case element(Element<Input, Output>)
    }
    
    public var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
            case let .elementButtonTapped(element):
                state.destination = .element(element)
                return .none
            case .addElementButtonTapped:
                let element = Element<Input, Output>.State.init(input: input())
                state.elements.append(element)
                state.destination = .init(.element(element))
                return .none
            case .elements, .destination:
                return .none
            case .deleteButtonTapped(id: let id):
                state.elements[id: id] = nil
                return .none
            }
        }
        .forEach(\.elements, action: \.elements) {
            Element<Input, Output>()
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.destination?.element) { oldValue, newValue in
            Reduce { state, action in
                
                guard let id = newValue?.id else {
                    return .none
                }
                
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
        public let navigationLinkLabel: (Bindable<StoreOf<Element<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: (Bindable<StoreOf<Element<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<CollectionFeature>,
            @ViewBuilder navigationLinkLabel: @escaping (Bindable<StoreOf<Element<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @escaping (Bindable<StoreOf<Element<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            List {
                ForEach(store.scope(state: \.elements, action: \.elements)) { elementStore in
                    Button {
                        store.send(.elementButtonTapped(elementStore.state))
                    } label: {
                        Element.LabelView.init(store: elementStore, navigationLinkLabel: navigationLinkLabel)
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
                Element.DestinationView.init(store: localStore, navigationLinkDestination: navigationLinkDestination)
                    .onAppear{
                        localStore.send(.delegate(.onAppear(localStore.input)))
                    }
                    .onDisappear{
                        localStore.send(.delegate(.onDissapear))
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
