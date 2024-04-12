//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import MemberwiseInit

@MemberwiseInit(.public)
@Reducer
public struct Element<
    Input: Codable & Hashable,
    Output: Codable & Hashable
> {
    @ObservableState
    @dynamicMemberLookup
    public struct State: Codable, Hashable, Identifiable {
        @Init(default: UUID())
        public let id: UUID
        public var input:Input
        @Shared(.fileStorage(.documentsDirectory.appending(path: "output.json"))) public var output:Output? = nil
        
        public init(
            id: UUID = UUID(),
            input: Input
        ) {
            self.id = id
            self.input = input
        }
        
        public subscript<T>(dynamicMember keyPath: WritableKeyPath<Input, T>) -> T {
            input[keyPath: keyPath]
        }
        
        public subscript<T>(dynamicMember keyPath: KeyPath<Output?, T>) -> T? {
            output?[keyPath: keyPath]
        }
        
        public subscript<T>(dynamicMember keyPath: KeyPath<Output?, T?>) -> T? {
            output?[keyPath: keyPath]
        }
        
        public subscript<T>(dynamicMember keyPath: KeyPath<Output, T?>) -> T? {
            output?[keyPath: keyPath]
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        
        @CasePathable
        public enum Delegate {
            case onAppear(Input)
            case onDissapear
            case inputUpdated(Input)
        }
        
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
            .onChange(of: \.input) { oldValue, newValue in
                Reduce { state, action in
                        .send(.delegate(.inputUpdated(newValue)))
                }
            }
    }
}

extension Shared: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            self.init(try decoder.singleValueContainer().decode(Value.self))
        } catch {
            self.init(try .init(from: decoder))
        }
    }
}


extension Element {
    public struct LabelView<
        NavigationLinkLabelView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<Element<Input, Output>>
        public let navigationLinkLabel: (Bindable<StoreOf<Element<Input, Output>>>)-> NavigationLinkLabelView
        
        @SwiftUI.State var sheet: Bool = false
        
        public init(
            store: StoreOf<Element<Input, Output>>,
            navigationLinkLabel: @escaping (Bindable<StoreOf<Element<Input, Output>>>) -> NavigationLinkLabelView
        ) {
            self.store = store
            self.navigationLinkLabel = navigationLinkLabel
        }
        
        public var body: some SwiftUI.View {
            self.navigationLinkLabel($store)
        }
    }
    
    public struct DestinationView<
        NavigationLinkDestinationView: SwiftUI.View
    >: SwiftUI.View {
        @Bindable var store: StoreOf<Element<Input, Output>>
        public let navigationLinkDestination: (Bindable<StoreOf<Element<Input, Output>>>)-> NavigationLinkDestinationView
        
        @SwiftUI.State var sheet: Bool = false
        
        public init(
            store: StoreOf<Element<Input, Output>>,
            navigationLinkDestination: @escaping (Bindable<StoreOf<Element<Input, Output>>>) -> NavigationLinkDestinationView
        ) {
            self.store = store
            self.navigationLinkDestination = navigationLinkDestination
        }
        
        public var body: some SwiftUI.View {
            self.navigationLinkDestination($store)
                
        }
    }
}






