//
//  File.swift
//
//
//  Created by Coen ten Thije Boonkkamp on 13-03-2024.
//

import Foundation
import ComposableArchitecture
import UserNotificationClient
#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

extension HigherOrderApp {
    @Reducer
    public struct Delegate {
        public struct State: Equatable {
            public init() {}
        }
        
#if os(iOS)
        public enum Action: Sendable {
            case didFinishLaunching
            case applicationWillTerminate
            case open(url:URL)
//            case performActionFor(shortcutItem: UIApplicationShortcutItem)
//            case `continue`(userActivity: NSUserActivity)
            case didRegisterForRemoteNotifications(Result<Data, Error>)
            case userNotifications(UserNotificationClient.DelegateEvent)
        }
#endif
        
#if os(macOS)
        public enum Action {
            case didFinishLaunching
            case applicationWillTerminate
        }
#endif
        public var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .didFinishLaunching:
                    return .none
                case .applicationWillTerminate:
                    return .none
                case .open(url: let url):
                    return .none
                case let .didRegisterForRemoteNotifications(.success(data)):
                    return .none
                case .didRegisterForRemoteNotifications(.failure):
                  return .none
                case .userNotifications(.didReceiveResponse(_, completionHandler: let completionHandler)):
                    return .none
                case let .userNotifications(.openSettingsForNotification(notification)):
                    return .none
                case let .userNotifications(.willPresentNotification(notification, completionHandler)):
                  return .run { _ in
                      completionHandler(.banner)
                  }
                }
            }
        }
    }
}
