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
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
> : Sendable{

    public let input: @Sendable () -> Input
    public let output: @Sendable  (Input) async throws -> Output
    
    @ObservableState
    public struct State {
        public var appDelegate: HigherOrderApp.Delegate.State
//        @Presents public var destination: HigherOrderApp.Destination.State?
        @Shared public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>
        public var collectionFeature: CollectionFeature<Input, Output>.State
        
        public init(
            appDelegate: HigherOrderApp.Delegate.State = HigherOrderApp.Delegate.State(),
//            destination: HigherOrderApp.Destination.State? = nil,
            elements: Shared<IdentifiedArrayOf<ElementFeature<Input, Output>.State>>
        ) {
            self.appDelegate = appDelegate
//            self.destination = destination
            self._elements = elements
            self.collectionFeature = .init(elements: elements)
        }
    }
    
    @CasePathable
    public enum Action: Sendable{
        case appDelegate(HigherOrderApp.Delegate.Action)
        case didChange(DidChange)
//        case destination(PresentationAction<Destination.Action>)
        case collectionFeature(CollectionFeature<Input, Output>.Action)
        case setOutput(ElementFeature<Input, Output>.State.ID, Output)
        
        @CasePathable
        public enum DidChange: Sendable {
            case scenePhase(old: ScenePhase, new: ScenePhase)
        }
    }
    
    @Reducer
    public struct Destination {
        public let input: ()->Input
        public let output: @Sendable (Input) async throws -> Output
        
        @CasePathable
        @dynamicMemberLookup
        @ObservableState
        public enum State {
            case collectionFeature(CollectionFeature<Input, Output>.State)
        }
        
        @CasePathable
        public enum Action: Sendable {
            case collectionFeature(CollectionFeature<Input, Output>.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.collectionFeature, action: \.collectionFeature) {
                CollectionFeature<Input, Output>(input: input, output: output)
            }
        }
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    public var body: some ReducerOf<Self> {
        
        Scope(state: \.collectionFeature, action: \.collectionFeature) {
            CollectionFeature<Input, Output>(input: input, output: output)
        }
        
        
        Reduce { state, action in
            switch action {
            case .collectionFeature(.destination(.dismiss)):
//                state.output = nil
                return .none
            
            case let .collectionFeature(.destination(.presented(.element(.delegate(delegate))))):
                switch delegate {
                case let .onAppear(id, input):
                    return .run { [element = state.collectionFeature.elements[id: id] ] send in
                        
                        if element?.output == nil {
                            try await send(.setOutput(id, output(input)))
                        }
                    }
                case let .inputUpdated(id, input):
                    return .run { send in
                        let output = try await output(input)
                        await send(.setOutput(id, output))
                        
                    }
                    .throttle(id: ThrottleID.inputUpdated, for: .milliseconds(300), scheduler: mainQueue, latest: true)
                }
            case let .setOutput(id, output):
                print("case let .setOutput(id, output):")
                state.collectionFeature.elements[id: id]?.output = output               
                state.collectionFeature.destination?.element?.output = output
                
                return .none
            default:
                return .none
            }
        }

        
        Reduce { state, action in
            switch action {
            case .appDelegate(.applicationWillTerminate):
//                state.output = nil
                return .none
            default:
                return .none
            }
        }
        
    }
}

extension HigherOrderApp {
    public struct View<
        MainView: SwiftUI.View,
        NavigationLinkDestinationView: SwiftUI.View,
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store:StoreOf<HigherOrderApp>
        public let mainView: (Bindable<StoreOf<HigherOrderApp<Input, Output>>>, CollectionFeature<Input, Output>.View<NavigationLinkDestinationView, NavigationLinkLabelView>) -> MainView
        public let navigationLinkLabel: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkLabelView
        public let navigationLinkDestination: @MainActor (Bindable<StoreOf<ElementFeature<Input, Output>>>)-> NavigationLinkDestinationView
        
        public init(
            store: StoreOf<HigherOrderApp>,
            mainView: @escaping (Bindable<StoreOf<HigherOrderApp<Input, Output>>>, CollectionFeature<Input, Output>.View<NavigationLinkDestinationView, NavigationLinkLabelView>) -> MainView,
            @ViewBuilder navigationLinkLabel: @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkLabelView,
            @ViewBuilder navigationLinkDestination: @escaping (Bindable<StoreOf<ElementFeature<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.mainView = mainView
            self.navigationLinkLabel = navigationLinkLabel
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            NavigationStack {
                mainView(
                    $store,
                    CollectionFeature.View.init(
                        store: self.store.scope(state: \.collectionFeature, action: \.collectionFeature),
                        navigationLinkLabel: self.navigationLinkLabel,
                        navigationLinkDestination: self.navigationLinkDestination
                    )
                )
            }
        }
    }
}

fileprivate enum ThrottleID { case inputUpdated }
