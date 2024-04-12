// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let higherOrderApp: Self = "HigherOrderApp"
    static let collectionFeature: Self = "CollectionFeature"
    static let element: Self = "Element"
    static let views: Self = "Views"
    static let example: Self = "Example"
}

extension Target.Dependency {
    static let higherOrderApp: Self = .target(name: .higherOrderApp)
    static let collectionFeature: Self = .target(name: .collectionFeature)
    static let element: Self = .target(name: .element)
    static let views: Self = .target(name: .views)
    static let example: Self = .target(name: .example)
}

extension Target.Dependency {
    static let memberwiseInit: Self = .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro")
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
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
            name: .element,
            targets: [.element]
        ),
        .library(
            name: .collectionFeature,
            targets: [.collectionFeature]
        ),
        .library(
            name: .views,
            targets: [.views]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "shared-state-beta"),
    ],
    targets: [
        .target(
            name: .higherOrderApp,
            dependencies: .shared + [.views, .element, .collectionFeature]
        ),
        .target(
            name: .collectionFeature,
            dependencies: .shared + [.element]
        ),
        .target(
            name: .element,
            dependencies: .shared + []
        ),
        .target(
            name: .views,
            dependencies: .shared + []
        ),
    ]
)

extension [Target.Dependency] {
    static let shared:Self = [
        .memberwiseInit,
        .composableArchitecture
    ]
}
