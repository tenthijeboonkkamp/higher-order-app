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
import ToolKit

@Reducer
public struct CollectionFeature<
    Input: Codable & Hashable & Sendable,
    Output: Codable & Hashable & Sendable
> {
    let input: @Sendable ()->Input
    let output: @Sendable (Input) async throws -> Output
    let reducer: @Sendable (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
    let searchable: Searchable?
    
    public struct Searchable: Sendable {
        public let predicate: @Sendable (String) -> (ElementFeature<Input, Output>.State) async -> Bool
        
        public init(_ predicate: @Sendable @escaping (String) -> (@Sendable (ElementFeature<Input, Output>.State) async -> Bool)) {
            self.predicate = predicate
        }
        
        public init(_ predicate: @Sendable @escaping (String, ElementFeature<Input, Output>.State) async -> Bool) {
            self = .init(curry(predicate))
        }
    }
    
    public init(
        input: @Sendable @escaping ()->Input,
        output: @Sendable @escaping (Input) async throws -> Output,
        reducer: @Sendable @escaping (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>,
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
                        
                        
                        if newValue.isEmpty {
                            state.filteredElements = state.elements
                        }
                        
                        return .run { [elements = state.elements, text = state.searchable.text] send in
                            await send(.updateFilter( await elements.filter(predicate(text))))
                            print("run")
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

public func curry<A, B, C>(_ first: @Sendable @escaping (A, B) async -> C) -> @Sendable (A) -> (B) async -> C {
    return { a in
        { b in
            await first(a, b)
        }
    }
}

public func curry<A, B, C>(_ first: @Sendable @escaping (A, inout B) async -> C) -> @Sendable (A) -> (inout B) async -> C {
    return { a in
        { b in
            await first(a, &b)
        }
    }
}


extension CollectionFeature {
    @ObservableState
    public struct State: Equatable {
        public static func == (lhs: CollectionFeature<Input, Output>.State, rhs: CollectionFeature<Input, Output>.State) -> Bool {
            lhs.elements == rhs.elements
            && lhs.searchable == rhs.searchable
            && lhs.filteredElements == rhs.filteredElements
        }
        
        @Shared public var elements: IdentifiedArrayOf<ElementFeature<Input, Output>.State>
        @Presents public var destination: CollectionFeature.Destination.State?
        var searchable: Searchable
        var filteredElements: IdentifiedArrayOf<ElementFeature<Input, Output>.State> = []
        
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
        public let reducer: @Sendable (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action>
        
        public init(
            reducer: @Sendable @escaping (inout ElementFeature<Input, Output>.State, ElementFeature<Input, Output>.Action) -> Effect<ElementFeature<Input, Output>.Action> = { _, _ in .none }
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

fileprivate enum ThrottleID { case searchUpdated }




extension IdentifiedArray where Element: Identifiable, Element.ID == ID {
    /// Asynchronously filters the elements of `IdentifiedArray` using the provided predicate, with parallel processing.
    func filter(_ predicate: @escaping (Element) async -> Bool) async -> IdentifiedArray<ID, Element> {
        print("run")
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
