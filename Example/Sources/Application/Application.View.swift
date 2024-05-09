//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 07-05-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import HigherOrderAppWithCollection
import Output

extension Application {
    public struct View: SwiftUI.View {
        @Bindable var store: StoreOf<Application>
        
        public init(store: StoreOf<Application>) {
            self.store = store
        }
        
        public var body: some SwiftUI.View {
            TabView {
                HigherOrderAppWithCollection.View(store: store) { $store in
                    VStack(alignment: .leading, spacing: 2.5) {
                        SwiftUI.Text("\(!store.string.isEmpty ? store.string : "new element")")
                        SwiftUI.Text("bool: \(String(describing: store.bool))")
                        if store.output?.calculation == true {
                            Text("store.output.calculation == true")
                        } else {
                            Text("store.output.calculation == false")
                        }
                    }
                    .foregroundStyle(Color.primary)
                    .navigationTitle("Higher Order with Collection")
                } navigationLinkDestination: { $store in
                    Form {
                        if store.output?.calculation == true {
                            Text("store.output.calculation == true")
                        } else {
                            Text("store.output.calculation == false")
                        }
                        
                        Text("\(store.output?.string ?? "")")
                        
                        TextField("string", text: $store.input.string)
                        
                        Bool?.View(
                            question: "question?",
                            answer: $store.input.bool
                        )
                    }
                    .navigationTitle(store.string)
                }
                
                .tabItem {
                    Label(
                        title: { Text(store.elements.count > 1 ? "Cases" : "Case" ) },
                        icon: { Image(systemName: "heart.text.square") }
                    )
                }
                
                
                NavigationStack {
                    Form {
                        Section {
                            HStack(spacing: 20) {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .padding(2.5)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Coen ten Thije Boonkkamp")
                                        .font(.title3)
                                        .lineLimit(1)
                                    Text("rule.legal")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            ColorPicker(
                                selection: ($store.higherOrder.tint ?? .red).animation()
                            ) {
                                HStack {
                                    Text("App Tint")
                                    if store.higherOrder.tint != nil {
                                        Spacer()
                                        Button {
                                            withAnimation {
                                                store.higherOrder.tint = nil
                                            }
                                        } label: {
                                            Text("reset")
                                                .font(.subheadline)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        Section {
                            Label(
                                title: { Text("Account") },
                                icon: { Image(systemName: "key") }
                            )
                            
                            Label(
                                title: { Text("Privacy") },
                                icon: { Image(systemName: "lock") }
                            )
                            
                            Label(
                                title: { Text("Cases") },
                                icon: { Image(systemName: "heart.text.square") }
                            )
                            
                            Label(
                                title: { Text("Notifications") },
                                icon: { Image(systemName: "app.badge") }
                            )
                        }
                        
                        Section {
                            Label(
                                title: { Text("Help") },
                                icon: { Image(systemName: "info.circle") }
                            )
                            
                            Label(
                                title: { Text("Tell a friend") },
                                icon: { Image(systemName: "heart") }
                            )
                        }
                    }
                    .navigationTitle("Settings")
                    
                    
                }
                .tabItem {
                    Label(
                        title: { Text("Settings") },
                        icon: { Image(systemName: "gear") }
                    )
                    
                }
            }
            
            .tint(.primary)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

