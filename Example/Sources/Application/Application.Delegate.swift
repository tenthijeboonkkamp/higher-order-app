//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 07-05-2024.
//

import Foundation
import HigherOrderApp
import Output
import SwiftUI
import ComposableArchitecture

extension Application {
    public final class Delegate: NSObject, UIApplicationDelegate {
        public let store:StoreOf<Application> = .default
        
        public func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            self.store.send(.appDelegate(.didFinishLaunching))
            return true
        }
        
        public func applicationWillTerminate(_ application: UIApplication) {
            self.store.send(.appDelegate(.applicationWillTerminate))
        }
    }
}
