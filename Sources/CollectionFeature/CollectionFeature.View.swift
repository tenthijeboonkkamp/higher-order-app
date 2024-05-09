//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 09-05-2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import MemberwiseInit
import ElementFeature



extension CollectionFeature {
    public struct View<
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<CollectionFeature>
        public let navigationLinkLabel: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView
        public let navigationLinkDestination: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        
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
                ForEach(
                    store.searchable.isPresented
                    ? store.scope(state: \.filteredElements, action: \.elements)
                    : store.scope(state: \.elements, action: \.elements)
                ) { elementStore in
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
                        .tint(Color.red)
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
            
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .toolbar {
                Button {
                    store.send(.addElementButtonTapped)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .font(.title2)
                }
            }
            .searchable(
                text: $store.searchable.text.animation(),
                isPresented: $store.searchable.isPresented.animation()
            )
        }
    }
}



//
//#Preview {
//    struct Input: Codable & Hashable & Sendable {
//        var string:String = ""
//    }
//
//    struct Output: Codable & Hashable & Sendable {
//        var bool: Bool = false
//
//        init(bool:Bool = false){
//            self.bool = bool
//        }
//
//        init(input:Input) async throws {
//            self = .init(bool: input.string == "" ? true : false)
//        }
//    }
//
//    let store = StoreOf<CollectionFeature<Input, Output>>.init(
//        initialState: .init(
//            searchable: Shared(CollectionFeature<Input, Output>.Searchable.init(text: "", isPresented: false)),
//            elements: Shared.init(IdentifiedArrayOf<ElementFeature<Input, Output>.State>.init(uniqueElements: []))
//        ),
//        reducer: {
//            CollectionFeature<Input, Output>.init(
//                input: Input.init,
//                output: Output.init,
//                reducer: { state, action in .none },
//                searchable.predicate: nil
//            )
//        }
//    )
//
//    return NavigationStack {
//        CollectionFeature.View(
//            store: store,
//            navigationLinkLabel: { $store in
//                Text(store.string)
//            },
//            navigationLinkDestination: { $store in
//                Text(store.string)
//            }
//        )
//    }
//}
