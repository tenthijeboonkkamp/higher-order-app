import Combine
import ComposableArchitecture
@preconcurrency import UserNotifications

@DependencyClient
public struct UserNotificationClient {
    public var add: @Sendable (UNNotificationRequest) async throws -> Void
    public var delegate: @Sendable () -> AsyncStream<DelegateEvent> = { .finished }
    public var getNotificationSettings: @Sendable () async -> UserNotificationClient.Settings = {
        UserNotificationClient.Settings(authorizationStatus: .notDetermined)
    }
    public var removeDeliveredNotificationsWithIdentifiers: @Sendable ([String]) async -> Void
    public var removePendingNotificationRequestsWithIdentifiers: @Sendable ([String]) async -> Void
    public var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool
    
    @CasePathable
    public enum DelegateEvent: Sendable {
        case didReceiveResponse(
            Notification.Response,
            completionHandler: @Sendable () -> Void
        )
        case openSettingsForNotification(
            Notification?
        )
        case willPresentNotification(
            Notification,
            completionHandler: @Sendable (UNNotificationPresentationOptions) -> Void
        )
    }
    
    public struct Notification: Equatable, Sendable {
        public var date: Date
        public var request: UNNotificationRequest
        
        public init(
            date: Date,
            request: UNNotificationRequest
        ) {
            self.date = date
            self.request = request
        }
        
        public struct Response: Equatable, Sendable {
            public var notification: Notification
            
            public init(notification: Notification) {
                self.notification = notification
            }
        }
    }
}

extension UserNotificationClient {
    public struct Settings: Equatable {
        public var authorizationStatus: UNAuthorizationStatus
        
        public init(authorizationStatus: UNAuthorizationStatus) {
            self.authorizationStatus = authorizationStatus
        }
    }
}
