//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import ComposableArchitecture
import SwiftUI
import MemberwiseInit
import CollectionFeature
import ElementFeature
import Combine

@MemberwiseInit(.public)
@Reducer
public struct HigherOrderApp<
    Input: Codable & Hashable,
    Output: Codable & Hashable
> {

    public let input: () -> Input
    public let output: (Input) async throws -> Output
    
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
        @Shared(.fileStorage(.documentsDirectory.appending(path: "elements.json"))) public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State> = []
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
        case setOutput(Output)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.collectionFeature, action: \.collectionFeature) {
            CollectionFeature<Input, Output>(input: input)
        }
        
        Reduce { state, action in
            switch action {
            case let .collectionFeature(.destination(.presented(.element(.delegate(delegate))))):
                switch delegate {
                case let .onAppear(input):
                    print("onAppear")
                    return .run { send in
                        try await send(.setOutput(output(input)))
                    }
                case let .inputUpdated(input):
                    print("inputUpdated")
                    return .run { send in
                        try await send(.setOutput(output(input)))
                    }
                case .onDissapear:
                    print("onDissapear")
                    state.output = nil
                    return .none
                }
            case let .setOutput(output):
                print("setOutput")
                state.output = output
                return .none
            default:
                return .none
            }
            
        }
        
        Reduce { state, action in
            print(state.output == nil ? "nil" : "some")
            
            switch action {
            case .appDelegate(.applicationWillTerminate):
                state.output = nil
                return .none
            default:
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
        public let navigationLinkLabel: (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<HigherOrderApp>,
            @ViewBuilder navigationLinkLabel: @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
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
