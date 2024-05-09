// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let higherOrderApp: Self = "HigherOrderApp"
    static let higherOrderAppWithCollection: Self = "HigherOrderAppWithCollection"
    static let collectionFeature: Self = "CollectionFeature"
    static let elementFeature: Self = "ElementFeature"
    static let views: Self = "Views"
}

extension Target.Dependency {
    static let higherOrderApp: Self = .target(name: .higherOrderApp)
    static let higherOrderAppWithCollection: Self = .target(name: .higherOrderAppWithCollection)
    static let collectionFeature: Self = .target(name: .collectionFeature)
    static let elementFeature: Self = .target(name: .elementFeature)
    static let views: Self = .target(name: .views)
}

extension String {
    static let storeKitClient:Self = "StoreKitClient"
    static let userNotificationClient:Self = "UserNotificationClient"
    static let remoteNotificationsClient:Self = "RemoteNotificationsClient"
}

extension Target.Dependency {
    static let userNotificationClient:Self = .target(name: .userNotificationClient)
    static let storeKitClient:Self = .target(name: .storeKitClient)
    static let remoteNotificationsClient:Self = .target(name: .remoteNotificationsClient)
}
extension Target.Dependency {
    static let tagged: Self = .product(name: "Tagged", package: "swift-tagged")
    static let memberwiseInit: Self = .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro")
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let toolKit: Self = .product(name: "ToolKit", package: "tenthijeboonkkamp-toolkit")
}

let package = Package(
    name: "higher-order-app",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: .higherOrderApp,
            targets: [.higherOrderApp]
        ),
        .library(
            name: .higherOrderAppWithCollection,
            targets: [.higherOrderAppWithCollection]
        ),
        .library(
            name: .elementFeature,
            targets: [.elementFeature]
        ),
        .library(
            name: .collectionFeature,
            targets: [.collectionFeature]
        ),
        .library(
            name: .views,
            targets: [.views]
        ),
        .library(
            name: .userNotificationClient,
            targets: [.userNotificationClient]
        ),
        .library(
            name: .storeKitClient,
            targets: [.storeKitClient]
        ),
        .library(
            name: .remoteNotificationsClient,
            targets: [.remoteNotificationsClient]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
        .package(url: "https://github.com/tenthijeboonkkamp/tenthijeboonkkamp-toolkit.git", branch: "main"),
    ],
    targets: [
        .target(
            name: .higherOrderApp,
            dependencies: .shared + [.views, .elementFeature, .collectionFeature, .userNotificationClient],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: .higherOrderAppWithCollection,
            dependencies: .shared + [.higherOrderApp, .collectionFeature, .views, .userNotificationClient],
            swiftSettings: [
              .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: .collectionFeature,
            dependencies: .shared + [.elementFeature]
        ),
        .target(
            name: .elementFeature,
            dependencies: .shared + []
        ),
        .target(
            name: .views,
            dependencies: .shared + []
        ),
        .target(
            name: .userNotificationClient,
            dependencies: .shared + []
        ),
        .target(
            name: .storeKitClient,
            dependencies: .shared + []
        ),
        .target(
            name: .remoteNotificationsClient,
            dependencies: .shared + []
        ),
    ]
)

extension [Target.Dependency] {
    static let shared:Self = [
        .memberwiseInit,
        .composableArchitecture,
        .tagged,
        .toolKit
    ]
}
