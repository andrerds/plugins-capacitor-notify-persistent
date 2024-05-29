// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorNotifyPersistent",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "CapacitorNotifyPersistent",
            targets: ["NotifyPersistentPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "NotifyPersistentPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/NotifyPersistentPlugin"),
        .testTarget(
            name: "NotifyPersistentPluginTests",
            dependencies: ["NotifyPersistentPlugin"],
            path: "ios/Tests/NotifyPersistentPluginTests")
    ]
)
