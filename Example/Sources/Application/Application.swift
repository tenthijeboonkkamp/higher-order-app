//
//  File.swift
//  
//
//  Created by Coen ten Thije Boonkkamp on 09-04-2024.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import HigherOrderApp
import Output

public typealias Application = HigherOrderApp<Input, Output>

extension Application {
    public static let `default`:Self = Application(
        input: { Input.init() },
        output: Output.init
    )
}
extension Application {
    public static func `default`(store: StoreOf<Application>) -> some SwiftUI.View {
        return Application.View(
            store: store,
            navigationLinkLabel: { $store in
                SwiftUI.Text("\(!store.string.isEmpty ? store.string : "empty")")
            },
            navigationLinkDestination: { $store in
                Form {
                    
                    if store.output?.calculation == true {
                        Text("store.output.calculation == true")
                    } else {
                        Text("store.output.calculation == false")
                    }
                    
                    TextField("string", text: $store.input.string)
                    Bool?.View(
                        question: "question?",
                        answer: $store.input.bool
                    )
                }
            }
        )
    }
}

extension Application {
    public final class Delegate: NSObject, UIApplicationDelegate {
        public let store:StoreOf<Application> = Store(
            initialState: Application.State.init()
        ) {
            Application.default
        }
        
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
