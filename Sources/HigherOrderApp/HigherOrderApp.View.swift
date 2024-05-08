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
import Combine


extension HigherOrderApp {
    public struct View<
        MainView: SwiftUI.View,
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store:StoreOf<HigherOrderApp>
        public let mainView: @MainActor (Bindable<StoreOf<HigherOrderApp<Input, Output>>>, CollectionFeature<Input, Output>.View<NavigationLinkDestinationView, NavigationLinkLabelView>) -> MainView
        public let navigationLinkLabel: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<HigherOrderApp>,
            mainView: @MainActor @escaping (Bindable<StoreOf<HigherOrderApp<Input, Output>>>, CollectionFeature<Input, Output>.View<NavigationLinkDestinationView, NavigationLinkLabelView>) -> MainView,
            @ViewBuilder navigationLinkLabel: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @MainActor @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.mainView = mainView
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            if let collectionStore = self.store.scope(state: \.destination?.collectionFeature, action: \.destination.collectionFeature) {
                NavigationStack {
                    mainView(
                        $store,
                        CollectionFeature.View(
                            store: collectionStore,
                            navigationLinkLabel: self.navigationLinkLabel,
                            navigationLinkDestination: self.navigationLinkDestination
                        )
                    )
                }
                .tint(store.tint)
                
            } else {
                Text("FAIL")
            }
        }
    }
}
