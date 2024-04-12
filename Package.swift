// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let higherOrderApp: Self = "HigherOrderApp"
    static let collectionFeature: Self = "CollectionFeature"
    static let onboarding: Self = "Onboarding"
    static let row: Self = "Row"
    static let views: Self = "Views"
    static let example: Self = "Example"
}

extension Target.Dependency {
    static let higherOrderApp: Self = .target(name: .higherOrderApp)
    static let collectionFeature: Self = .target(name: .collectionFeature)
    static let onboarding: Self = .target(name: .onboarding)
    static let row: Self = .target(name: .row)
    static let views: Self = .target(name: .views)
    static let example: Self = .target(name: .example)
}

extension Target.Dependency {
    static let casePaths: Self = .product(name: "CasePaths", package: "swift-case-paths")
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
    static let dependencies: Self = .product(name: "Dependencies", package: "swift-dependencies")
    static let languages: Self = .product(name: "Languages", package: "swift-language")
    static let percent: Self = .product(name: "Percent", package: "swift-percent")
    static let toolkit: Self = .product(name: "ToolKit", package: "tenthijeboonkkamp-toolkit")
    static let money: Self = .product(name: "Money", package: "swift-money")
    static let memberwiseInit: Self = .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro")
    static let macroCodableKit: Self = .product(name: "MacroCodableKit", package: "macro-codable-kit")
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
            name: .row,
            targets: [.row]
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
        .package(url: "https://github.com/mikhailmaslo/macro-codable-kit.git", from: "0.3.0"),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.2.4"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "shared-state-beta"),
        .package(url: "git@github.com:tenthijeboonkkamp/swift-language.git", branch: "main"),
        .package(url: "git@github.com:tenthijeboonkkamp/swift-percent.git", branch: "main"),
        .package(url: "git@github.com:tenthijeboonkkamp/swift-money.git", branch: "main"),
        .package(url: "git@github.com:tenthijeboonkkamp/tenthijeboonkkamp-toolkit.git", branch: "main")
    ],
    targets: [
        .target(
            name: .higherOrderApp,
            dependencies: .shared + [.views, .row, .collectionFeature]
        ),
        .target(
            name: .collectionFeature,
            dependencies: .shared + [.row]
        ),
        .target(
            name: .row,
            dependencies: .shared + []
        ),
        .target(
            name: .views,
            dependencies: .shared + []
        ),
        .target(
            name: .onboarding,
            dependencies: .shared + [.row]
        ),
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
