// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let application: Self = "Application"
    static let output: Self = "Output"
}

extension Target.Dependency {
    static let application: Self = .target(name: .application)
    static let output: Self = .target(name: .output)
}

extension Target.Dependency {
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let higherOrderApp: Self = .product(name: "HigherOrderApp", package: "higher-order-app")
    static let memberwiseInit: Self = .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro")
}

let package = Package(
    name: "higher-order-app-example",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: .application,
            targets: [.application]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "shared-state-beta"),
        .package(url: "git@github.com:tenthijeboonkkamp/higher-order-app.git", branch: "main"),
    ],
    targets: [
        .target(
            name: .application,
            dependencies: .shared + [.higherOrderApp, .output]
        ),
        .target(
            name: .output,
            dependencies: .shared
        )
    ]
)

extension [Target.Dependency] {
    static let shared:Self = [
        .memberwiseInit,
        .composableArchitecture
    ]
}
