//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit
//import Onboarding
import CollectionFeature
import Row
import Combine

@MemberwiseInit(.public)
@Reducer
public struct HigherOrderApp<
    Input: Codable & Hashable,
    Output: Codable & Hashable
> {
    
    public let input: ()->Input
    public let output: (Input)->Output
    
    @Reducer
    public struct Destination {
        public let input: ()->Input
        //        case collectionFeature(CollectionFeature<Input, Output>)
        
        @CasePathable
        @dynamicMemberLookup
        @ObservableState
        public enum State {
            case collectionFeature(CollectionFeature<Input, Output> .State)
        }
        
        @CasePathable
        public enum Action {
            case collectionFeature(CollectionFeature<Input, Output> .Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.collectionFeature, action: \.collectionFeature) {
                CollectionFeature<Input, Output>(input: input)
            }
        }
    }
    
    @ObservableState
    public struct State {
        public var appDelegate: HigherOrderApp.Delegate.State
        @Presents public var destination: HigherOrderApp.Destination.State?
        @Shared(.fileStorage(.documentsDirectory.appending(path: "rows.json"))) public var rows: IdentifiedArrayOf<Row<Input, Output>.State> = []
        @Shared(.fileStorage(.documentsDirectory.appending(path: "output.json"))) var output:Output? = nil
        public var collectionFeature: CollectionFeature<Input, Output>.State
        
        public init(
            appDelegate: HigherOrderApp.Delegate.State = HigherOrderApp.Delegate.State(),
            destination: HigherOrderApp.Destination.State? = nil,
            collectionFeature: CollectionFeature<Input, Output>.State = .init()
        ) {
            self.appDelegate = appDelegate
            self.destination = destination
            self.collectionFeature = collectionFeature
        }
    }
    
    @CasePathable
    public enum Action {
        case appDelegate(HigherOrderApp.Delegate.Action)
        case didChangeScenePhase(ScenePhase)
        case destination(PresentationAction<Destination.Action>)
        case collectionFeature(CollectionFeature<Input, Output>.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.collectionFeature, action: \.collectionFeature) {
            CollectionFeature<Input, Output>(input: input)
        }
        
        Reduce { state, action in
            switch action {
            case let .collectionFeature(.destination(.presented(.row(.delegate(.onAppear(input)))))):
                print("test")
                state.output = output(input)
//                state.rows[id:id]?.output = output(input)
                return .none
            case let .collectionFeature(.destination(.presented(.row(.delegate(.inputUpdated(input)))))):
                print("test2")
                state.output = output(input)
//                state.rows[id:id]?.output = output(input)
                return .none
            default:
                return .none
            }
        }
        
        Scope(state: \.self, action: \.collectionFeature.rows.element) {
            Reduce { state, action in
                
                switch action {
//                case let .destination(.collectionFeature(collectionFeature)):
//                    return .none
//                case let (id, .delegate(.onAppear(input))):
//                    print("case let (id, .delegate(.onAppear(input))):")
//                    state.output = output(input)
//                    state.rows[id:id]?.output = output(input)
//                    return .none
//                    
//                case let (id, .delegate(.inputUpdated(input))):
//                    print("case let (id, .delegate(.inputUpdated(input))):")
//                    state.output = output(input)
//                    state.rows[id:id]?.output = output(input)
//                    return .none
                default:
                    return .none
                }
            }
        }

        Reduce { state, action in
            switch action {
            case .appDelegate, .didChangeScenePhase, .destination, .collectionFeature:
                return .none
            }
        }
    }
}


extension HigherOrderApp {
    public struct View<
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store:StoreOf<HigherOrderApp>
        public let navigationLinkLabel: (Bindable<StoreOf<Row<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: (Bindable<StoreOf<Row<Input, Output>>>)-> NavigationLinkDestinationView

        public init(
            store: StoreOf<HigherOrderApp>,
            @ViewBuilder navigationLinkLabel: @escaping (Bindable<StoreOf<Row<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @escaping (Bindable<StoreOf<Row<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            NavigationStack {
                CollectionFeature.View.init(
                    store: store.scope(state: \.collectionFeature, action: \.collectionFeature),
                    navigationLinkLabel: self.navigationLinkLabel,
                    navigationLinkDestination: self.navigationLinkDestination
                )
            }
        }
    }
}



//            if store.collectionFeature.rows.count < 1 {
//                Onboarding.View(store: store.scope(state: \.onboarding, action: \.onboarding))
//            } else {
//                Text("More than 1 row already added")
//            }
