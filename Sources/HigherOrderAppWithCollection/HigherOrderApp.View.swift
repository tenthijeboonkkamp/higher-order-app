//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 08-05-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit
import CollectionFeature
import ElementFeature
import HigherOrderApp

extension HigherOrderAppWithCollection {
    public struct View<
//        MainView: SwiftUI.View,
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<HigherOrderAppWithCollection<Input, Output>>
//        public let mainView:  @MainActor (
//            Bindable<StoreOf<HigherOrderAppWithCollection<Input, Output>>>,
//            CollectionFeature<Input, Output>.View<NavigationLinkDestinationView, NavigationLinkLabelView>
//        ) -> MainView
        public let navigationLinkLabel: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<HigherOrderAppWithCollection<Input, Output>>,
//            mainView: @MainActor @escaping (
//                Bindable<StoreOf<HigherOrderAppWithCollection<Input, Output>>>,
//                CollectionFeature<Input, Output>.View<NavigationLinkDestinationView, NavigationLinkLabelView>
//            ) -> MainView,
            @ViewBuilder navigationLinkLabel: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
//            self.mainView = mainView
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            HigherOrderApp.View.init(
                store: self.store.scope(state: \.higherOrder, action: \.higherOrder),
                mainView: { $store in
                    Group {
                        if let collectionStore = store.scope(state: \.destination?.collectionFeature, action: \.destination.collectionFeature) {
                            NavigationStack {
                                CollectionFeature.View(
                                    store: collectionStore,
                                    navigationLinkLabel: self.navigationLinkLabel,
                                    navigationLinkDestination: self.navigationLinkDestination
                                )
                            }
                            .tint(store.tint)
                        } else {
                            Text("FAIL")
                        }
                    }
                }
            )
        }
    }
}


