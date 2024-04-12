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
import Row



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
        @Shared(.fileStorage(.documentsDirectory.appending(path: "rows.json"))) public var rows: IdentifiedArrayOf<Row<Input, Output>.State> = []
        @Presents public var destination: CollectionFeature.Destination.State?
        
        public init(destination: CollectionFeature.Destination.State? = nil) {
            self.destination = destination
        }
    }
    
    public enum Action {
        case rows(IdentifiedActionOf<Row<Input, Output>>)
        case destination(PresentationAction<CollectionFeature.Destination.Action>)
        case rowButtonTapped(Row<Input, Output>.State)
        case addRowButtonTapped
        case deleteButtonTapped(id: Row<Input, Output>.State.ID)
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case row(Row<Input, Output>)
    }
    
    public var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
            case let .rowButtonTapped(row):
                state.destination = .row(row)
                return .none
            case .addRowButtonTapped:
                let row = Row<Input, Output>.State.init(input: input())
                state.rows.append(row)
                state.destination = .init(.row(row))
                return .none
            case .rows, .destination:
                return .none
            case .deleteButtonTapped(id: let id):
                state.rows[id: id] = nil
                return .none
            }
        }
        .forEach(\.rows, action: \.rows) {
            Row<Input, Output>()
        }
        .ifLet(\.$destination, action: \.destination)
        .onChange(of: \.destination?.row) { oldValue, newValue in
            Reduce { state, action in
                
                guard let id = newValue?.id else {
                    return .none
                }
                
                state.rows[id: id] = newValue
                return .none
            }
        }
    }
    
    public struct View<
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<CollectionFeature>
        public let navigationLinkLabel: (Bindable<StoreOf<Row<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: (Bindable<StoreOf<Row<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<CollectionFeature>,
            @ViewBuilder navigationLinkLabel: @escaping (Bindable<StoreOf<Row<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @escaping (Bindable<StoreOf<Row<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            List {
                ForEach(store.scope(state: \.rows, action: \.rows)) { rowStore in
                    Button {
                        store.send(.rowButtonTapped(rowStore.state))
                    } label: {
                        Row.LabelView.init(store: rowStore, navigationLinkLabel: navigationLinkLabel)
                    }
                    .swipeActions(allowsFullSwipe: true) {
                        Button(role: .destructive){
                            store.send(.deleteButtonTapped(id:  rowStore.id))
                        } label: {
                            Text("Delete")
                        }
                    }
                }
                
            }
            .navigationDestination(item: $store.scope(state: \.destination?.row, action: \.destination.row)) { localStore in
                Row.DestinationView.init(store: localStore, navigationLinkDestination: navigationLinkDestination)
                    .onAppear{
                        localStore.send(.delegate(.onAppear(localStore.input)))
                    }
            }
            .toolbar {
                Button {
                    store.send(.addRowButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }

        }
    }
}
