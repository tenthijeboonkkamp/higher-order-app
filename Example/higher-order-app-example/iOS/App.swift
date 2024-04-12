//
//  ExampleApp.swift
//  Example
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import SwiftUI
import ExampleApplication
import ComposableArchitecture

extension ExampleApplication {
    final class AppDelegate: NSObject, UIApplicationDelegate {
        let store:StoreOf<ExampleApplication> = Store(
            initialState: ExampleApplication.State.init()
        ) {
            ExampleApplication.default
        }
        
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            self.store.send(.appDelegate(.didFinishLaunching))
            return true
        }
    }
}

@main
struct ExampleApp: App {
    @UIApplicationDelegateAdaptor(ExampleApplication.AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ExampleApplication.default(store: self.appDelegate.store)
        }
        .onChange(of: self.scenePhase) { _, newPhase in
            self.appDelegate.store.send(.didChangeScenePhase(newPhase))
        }
    }
}
