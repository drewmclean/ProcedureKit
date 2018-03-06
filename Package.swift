// swift-tools-version:4.0

import PackageDescription

let pkg = Package(name: "ProcedureKit")

pkg.products = [
    .library(name: "ProcedureKit", targets: ["ProcedureKit"]),
    .library(name: "ProcedureKitCloud", targets: ["ProcedureKitCloud"]),
    .library(name: "ProcedureKitLocation", targets: ["ProcedureKitLocation"]),
    .library(name: "ProcedureKitMac", targets: ["ProcedureKitMac"]),
    .library(name: "ProcedureKitNetwork", targets: ["ProcedureKitNetwork"]),
    .library(name: "TestingProcedureKit", targets: ["TestingProcedureKit"])
]

pkg.targets = [
    .target(name: "ProcedureKit",
            path: "Sources/ProcedureKit"),
    .target(name: "ProcedureKitCloud",
            dependencies: ["ProcedureKit"],
            path: "Sources/ProcedureKitCloud"),
    .target(name: "ProcedureKitLocation",
            dependencies: ["ProcedureKit"],
            path: "Sources/ProcedureKitLocation"),
    .target(name: "ProcedureKitMac",
            dependencies: ["ProcedureKit"],
            path: "Sources/ProcedureKitMac"),
    .target(name: "ProcedureKitNetwork",
            dependencies: ["ProcedureKit"],
            path: "Sources/ProcedureKitNetwork"),
    .target(name: "TestingProcedureKit",
            dependencies: ["ProcedureKit"],
            path: "Sources/TestingProcedureKit"),
    .testTarget(name: "ProcedureKitTests",
                dependencies: ["ProcedureKit", "TestingProcedureKit"],
                path: "Tests/ProcedureKitTests"),
    .testTarget(name: "ProcedureKitStressTests",
                dependencies: ["ProcedureKit", "TestingProcedureKit"],
                path: "Tests/ProcedureKitStressTests"),
    .testTarget(name: "ProcedureKitCloudTests",
                dependencies: ["ProcedureKitCloud", "TestingProcedureKit"],
                path: "Tests/ProcedureKitCloudTests"),
    .testTarget(name: "ProcedureKitLocationTests",
                dependencies: ["ProcedureKitLocation", "TestingProcedureKit"],
                path: "Tests/ProcedureKitLocationTests"),
    .testTarget(name: "ProcedureKitMacTests",
                dependencies: ["ProcedureKitMac", "TestingProcedureKit"],
                path: "Tests/ProcedureKitMacTests"),
    .testTarget(name: "ProcedureKitNetworkTests",
                dependencies: ["ProcedureKitNetwork", "TestingProcedureKit"],
                path: "Tests/ProcedureKitNetworkTests"),
]

/*

let package = Package(
    name: "ProcedureKit",

    targets: [

        /** ProcedureKit libraries */
        Target(name: "ProcedureKit"),

        Target(
            name: "ProcedureKitCloud",
            dependencies: ["ProcedureKit"]),

        Target(
            name: "ProcedureKitLocation",
            dependencies: ["ProcedureKit"]),

        Target(
            name: "ProcedureKitMac",
            dependencies: ["ProcedureKit"]),

        Target(
            name: "ProcedureKitNetwork",
            dependencies: ["ProcedureKit"]),

        /** Test Support library */
        Target(
            name: "TestingProcedureKit",
            dependencies: ["ProcedureKit"]),

        /** Test executables */
        Target(
            name: "ProcedureKitTests",
            dependencies: ["ProcedureKit", "TestingProcedureKit"]),

         Target(
            name: "ProcedureKitStressTests",
            dependencies: ["ProcedureKit", "TestingProcedureKit"]),

         Target(
            name: "ProcedureKitCloudTests",
            dependencies: ["ProcedureKitCloud", "TestingProcedureKit"]),

         Target(
            name: "ProcedureKitLocationTests",
            dependencies: ["ProcedureKitLocation", "TestingProcedureKit"]),

         Target(
            name: "ProcedureKitMacTests",
            dependencies: ["ProcedureKitMac", "TestingProcedureKit"]),

         Target(
            name: "ProcedureKitNetworkTests",
            dependencies: ["ProcedureKitNetwork", "TestingProcedureKit"])

    ],

    exclude: [
        "Sources/ProcedureKitMobile",
        "Sources/ProcedureKitTV",
        "Tests/ProcedureKitMobileTests",
        "Tests/ProcedureKitTVTests",
    ]
)

 */
