// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FENRVCUEmulator",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ProtocolCore", targets: ["ProtocolCore"]),
        .library(name: "VehicleSimulation", targets: ["VehicleSimulation"]),
        .library(name: "ProtocolEngine", targets: ["ProtocolEngine"]),
        .library(name: "BLEPeripheral", targets: ["BLEPeripheral"])
    ],
    targets: [
        .target(name: "ProtocolCore"),
        .target(name: "VehicleSimulation", dependencies: ["ProtocolCore"]),
        .target(name: "ProtocolEngine", dependencies: ["ProtocolCore", "VehicleSimulation"]),
        .target(name: "BLEPeripheral", dependencies: ["ProtocolCore", "ProtocolEngine"]),
        .testTarget(name: "ProtocolCoreTests", dependencies: ["ProtocolCore"]),
        .testTarget(name: "ProtocolEngineTests", dependencies: ["ProtocolEngine"])
    ]
)
