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
import ElementFeature




@Reducer
public struct CollectionFeature<
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
> {
    let input: @Sendable ()->Input
    let output: @Sendable (Input) async throws -> Output
    let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
    let searchable: Searchable?
    
    public struct Searchable: Sendable {
        public let predicate: @Sendable (String) -> (ElementFeature<Input, Output>.State) async -> Bool
        
        public init(_ predicate: @Sendable @escaping (String) -> (@Sendable (ElementFeature<Input, Output>.State) async -> Bool)) {
            self.predicate = predicate
        }
        
        public init(_ predicate: @Sendable @escaping  (String, ElementFeature<Input, Output>.State) async  -> Bool) {
            self = .init(curry(predicate))
        }
    }
    
    public init(
        input: @Sendable @escaping ()->Input,
        output: @Sendable @escaping (Input) async throws -> Output,
        reducer: @Sendable @escaping (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>,
        searchable: Searchable?
        
    ) {
        self.input = input
        self.output = output
        self.reducer = reducer
        self.searchable = searchable
    }
    
    @Dependency(\.mainQueue) var mainQueue
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.searchable.isPresented) { oldValue, newValue in
                if searchable?.predicate != nil {
                    Reduce { state, action in
                        if oldValue == false && newValue == true {
                            state.filteredElements = state.elements
                        }
                        
                        if oldValue == true && newValue == false {
                            state.filteredElements = []
                        }
                        return .none
                    }
                }
            }
            .onChange(of: \.searchable.text) { oldValue, newValue in
                if let predicate = searchable?.predicate {
                    Reduce { state, action in
                        
                        guard !newValue.isEmpty
                        else {
                            state.filteredElements = state.elements
                            return .none
                        }
                        return .run { [elements = state.elements, text = state.searchable.text] send in
                            await send(.updateFilter( await elements.filterAsyncParallel(predicate(text))))
                        }
                        .throttle(id: ThrottleID.searchUpdated, for: .milliseconds(1000), scheduler: mainQueue, latest: true)
                    }
                }
            }
        
        Reduce { state, action in
            switch action {
            case let .elementButtonTapped(element):
                state.destination = .element(element)
                return .none
                
            case .addElementButtonTapped:
                let element = ElementFeature<Input, Output>.State.init(input: input(), output: nil)
                let _ = withAnimation {
                    state.elements.append(element)
                }
                state.destination = .init(.element(element))
                return .none
                
            case .destination(.dismiss):

                let input = input()
                
                withAnimation {
                    if let element = state.destination?.element {
                        state.elements[id: element.id] = element
                        state.filteredElements[id: element.id] = element
                    }
                    // This needs to come last for animations to work
                    state.elements.removeAll { $0.input == input }
                }
                
                return .none
                
            case .deleteButtonTapped(id: let id):
                state.destination = .alert(.deleteElement(id: id))
                return .none
                
            case let .destination(.presented(.alert(alertAction))):
                switch alertAction {
                case let .confirmDeletion(id):
                    withAnimation {
                        state.elements[id: id] = nil
                    }
                    return .none
                }
            case .elements, .destination, .binding:
                return .none
            case let .updateFilter(elements):
                state.filteredElements = elements
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination(reducer: self.reducer)
        }
    }
}

extension IdentifiedArray where Element: Identifiable, Element.ID == ID {
    /// Asynchronously filters the elements of `IdentifiedArray` using the provided predicate, with parallel processing.
    func filterAsyncParallel(_ predicate: @escaping (Element) async -> Bool) async -> IdentifiedArray<ID, Element> {
        var results: [Element] = []

        // Use a task group to perform parallel checks
        await withTaskGroup(of: Element?.self) { group in
            // Launch a task for each element
            for element in self {
                group.addTask {
                    return await predicate(element) ? element : nil
                }
            }
            
            // Collect non-nil results
            for await result in group {
                if let validResult = result {
                    results.append(validResult)
                }
            }
        }
        
        // Create a new IdentifiedArray from the filtered results
        return IdentifiedArray(uniqueElements: results)
    }
}



extension CollectionFeature {
    @ObservableState
    public struct State {
        @Shared public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>
        @Presents public var destination: CollectionFeature.Destination.State?
        var searchable: Searchable
        var filteredElements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>
        
        public struct Searchable: Equatable {
            public var text: String = ""
            public var isPresented: Bool = false
            
            public init(text: String, isPresented: Bool) {
                self.text = text
                self.isPresented = isPresented
            }
        }
        
        public init(
            elements: Shared<IdentifiedArrayOf<ElementFeature<Input, Output>.State>>,
            destination: CollectionFeature.Destination.State? = nil
        ) {
            self.searchable = .init(text: "", isPresented: false)
            self._elements = elements
            self.destination = destination
            self.filteredElements = elements.wrappedValue
        }
    }
    
    @CasePathable
    public enum Action: Sendable, BindableAction {
        case elements(IdentifiedActionOf<ElementFeature<Input, Output>>)
        case destination(PresentationAction<CollectionFeature.Destination.Action>)
        case elementButtonTapped(ElementFeature<Input, Output>.State)
        case addElementButtonTapped
        case deleteButtonTapped(id: ElementFeature<Input, Output>.State.ID)
        case updateFilter(IdentifiedArrayOf<ElementFeature<Input, Output>.State>)
        case binding(BindingAction<State>)
    }
    
    public struct Destination: Reducer {
        public let reducer: @Sendable (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
        
        public init(
            reducer: @Sendable @escaping (ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action> = { _, _ in .none }
        ) {
            self.reducer = reducer
        }
        
        @CasePathable
        @dynamicMemberLookup
        @ObservableState
        public enum State {
            case element(ElementFeature<Input, Output>.State)
            case alert(AlertState<Alert>)
        }
        
        @CasePathable
        public enum Action: Sendable {
            case element(ElementFeature<Input, Output> .Action)
            case alert(AlertState<Alert>.Action)
        }
        
        @CasePathable
        public enum Alert : Sendable{
            case confirmDeletion(id: UUID)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.element, action: \.element) {
                ElementFeature<Input, Output>(reducer: reducer)
            }
        }
    }
}

extension AlertState  {
    static func deleteElement<
        Input: Codable & Hashable & Sendable,
        Output: Codable & Hashable & Sendable
    >(id: UUID) -> Self
    where Action == CollectionFeature<Input, Output>.Destination.Alert {
        Self {
            TextState("Delete?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                TextState("Yes")
            }
            ButtonState(role: .cancel) {
                TextState("Nevermind")
            }
        } message: {
            TextState("Are you sure you want to delete this meeting?")
        }
    }
}

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
                if store.searchable.isPresented {
                    ForEach(store.scope(state: \.filteredElements, action: \.elements)) { elementStore in
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
                    
                } else {
                    ForEach(store.scope(state: \.elements, action: \.elements)) { elementStore in
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
//                Text(store.input.string)
//            },
//            navigationLinkDestination: { $store in
//                Text(store.input.string)
//            }
//        )
//    }
//}


private func curry<A, B, C>(_ first: @Sendable @escaping (A, B) -> C) -> @Sendable (A) -> (B) -> C {
    return { a in
        { b in
            first(a, b)
        }
    }
}

private func curry<A, B, C>(_ first: @Sendable @escaping (A, B) async -> C) -> @Sendable (A) -> (B) async -> C {
    return { a in
        { b in
            await first(a, b)
        }
    }
}
fileprivate enum ThrottleID { case searchUpdated }
