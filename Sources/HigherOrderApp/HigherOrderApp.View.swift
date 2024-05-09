//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 08-05-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit
import Combine

extension HigherOrderApp {
    public struct View<
        MainView: SwiftUI.View
//        Destination: Reducer
    >: SwiftUI.View {
        @Bindable var store:StoreOf<HigherOrderApp<Destination>>
        public let mainView: @MainActor (Bindable<StoreOf<HigherOrderApp<Destination>>>) -> MainView
        
        public init(
            store: StoreOf<HigherOrderApp<Destination>>,
            mainView: @MainActor @escaping (Bindable<StoreOf<HigherOrderApp<Destination>>>) -> MainView
        ) {
            self.store = store
            self.mainView = mainView
        }
        
        public var body: some SwiftUI.View {
            mainView($store)
                
        }
    }
}
