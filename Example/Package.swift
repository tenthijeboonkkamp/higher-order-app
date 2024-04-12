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
    static let casePaths: Self = .product(name: "CasePaths", package: "swift-case-paths")
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let languages: Self = .product(name: "Languages", package: "swift-language")
    static let percent: Self = .product(name: "Percent", package: "swift-percent")
    static let toolkit: Self = .product(name: "ToolKit", package: "tenthijeboonkkamp-toolkit")
    static let money: Self = .product(name: "Money", package: "swift-money")
    static let higherOrderApp: Self = .product(name: "HigherOrderApp", package: "higher-order-app")
    static let memberwiseInit: Self = .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro")
    static let macroCodableKit: Self = .product(name: "MacroCodableKit", package: "macro-codable-kit")
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
        .package(url: "https://github.com/mikhailmaslo/macro-codable-kit.git", from: "0.3.0"),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.2.4"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "shared-state-beta"),
        .package(url: "git@github.com:tenthijeboonkkamp/swift-language.git", branch: "main"),
        .package(url: "git@github.com:tenthijeboonkkamp/swift-percent.git", branch: "main"),
        .package(url: "git@github.com:tenthijeboonkkamp/swift-money.git", branch: "main"),
        .package(url: "git@github.com:tenthijeboonkkamp/tenthijeboonkkamp-toolkit.git", branch: "main"),
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
        .casePaths,
        .dependencies,
        .languages,
        .percent,
        .toolkit,
        .money,
        .memberwiseInit,
        .macroCodableKit,
        .composableArchitecture
    ]
}
