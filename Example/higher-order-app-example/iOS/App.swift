//
//  ExampleApp.swift
//  Example
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import SwiftUI
import Application

@main
struct Main: App {
    @UIApplicationDelegateAdaptor(Application.Delegate.self) private var delegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Application.View(store: self.delegate.store)
        }
        .onChange(of: self.scenePhase) { self.delegate.store.send(.higherOrder(.didChange(.scenePhase(old: $0, new: $1)))) }
    }
}
