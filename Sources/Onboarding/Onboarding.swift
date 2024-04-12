////
////  File.swift
////  
////
////  Created by Coen ten Thije Boonkkamp on 13-03-2024.
////
//
//import Foundation
//import ComposableArchitecture
//import SwiftUI
//import Row
//import MemberwiseInit
//
//
//extension PersistenceKey where Self == FileStorageKey<Input> {
//    fileprivate static var onboarding: Self {
//        fileStorage(.documentsDirectory.appending(path: "onboarding.json"))
//    }
//}
//
//
//@MemberwiseInit(.public)
//@Reducer
//public struct Onboarding {
//    @ObservableState
//    @MemberwiseInit(.public)
//    public struct State {
//        public var path:StackState<Path.State> = .init()
//        @Shared(.onboarding) public var row: Input = .init()
//    }
//    public enum Action {
//        case path(StackAction<Path.State, Path.Action>)
////        case row(Row.Action)
//    }
//
//    public var body: some ReducerOf<Self> {
//        
////        Scope(state: \.row, action: \.row) {
////            Row()
////        }
//        
//        Reduce { state, action in
//            switch action {
////            case .path(.element(id: _, action: .topics(.delegate(.stepFinished)))):
////                state.path.append(.summary(SummaryFeature.State(signUpData: state.$signUpData)))
////                return .none
//                
//            case .path:
//                return .none
//            }
//        }
//        .forEach(\.path, action: \.path)
//    }
//    
//    @Reducer
//    public enum Path {
//        case row(Row<Input, Output>)
//    }
//}
//
//extension Onboarding {
//    
//    public struct View: SwiftUI.View {
//        @Bindable var store:StoreOf<Onboarding>
//        
//        public init(store: StoreOf<Onboarding>) {
//            self.store = store
//        }
//        
//        var string:String {
//            store.row.researcher_name.isEmpty ? "Row.row details" : store.row.researcher_name
//        }
//        
//        public var body: some SwiftUI.View {
//            EmptyView()
////            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
////                Form {
////                    Section {
////                        Text("readMe")
////                    }
////                    Section {
////                        NavigationLink(
////                            string,
////                            state: Onboarding.Path.State.row(.init(input: store.$row))
////                        )
////                    }
////                }
////                .navigationTitle(string)
////            } destination: { store in
////                switch store.case {
////                case let .row(store):
////                    Row.View(store: store)
////                        .navigationTitle(store.researcher_name.isEmpty ? "Row details" : store.researcher_name)
////                }
////            }
//        }
//    }
//}
////
////@Reducer
////public struct OnboardingFull {
////    public struct State {
////        @Shared(.onboarding) public var input: Input = .init()
////    }
////    
////    public enum Action {
////        case row(Row.Action)
////    }
////    
//////    public var body: some ReducerOf<Self> {
//////        Scope(state: \.row, action: \.row) {
//////            Row()
//////        }
//////    }
////    
////    
////}
////
////extension OnboardingFull {
////    public struct View: SwiftUI.View {
////        @Bindable var store:StoreOf<OnboardingFull>
////        
////        public var body: some SwiftUI.View {
////            Row.View(store: store.scope(state: \.row, action: \.row))
////        }
////    }
////}
