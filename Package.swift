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
        .target(name: "ProtocolCore", path: "Modules/ProtocolCore/Sources"),
        .target(name: "VehicleSimulation", dependencies: ["ProtocolCore"], path: "Modules/VehicleSimulation/Sources"),
        .target(name: "ProtocolEngine", dependencies: ["ProtocolCore", "VehicleSimulation"], path: "Modules/ProtocolEngine/Sources"),
        .target(name: "BLEPeripheral", dependencies: ["ProtocolCore", "ProtocolEngine"], path: "Modules/BLEPeripheral/Sources"),
        .testTarget(name: "ProtocolCoreTests", dependencies: ["ProtocolCore"], path: "Modules/ProtocolCore/Tests"),
        .testTarget(name: "ProtocolEngineTests", dependencies: ["ProtocolEngine"], path: "Modules/ProtocolEngine/Tests"),
        .testTarget(name: "BLEPeripheralTests", dependencies: ["BLEPeripheral"], path: "Modules/BLEPeripheral/Tests"),
        .testTarget(name: "VehicleSimulationTests", dependencies: ["VehicleSimulation"], path: "Modules/VehicleSimulation/Tests")
    ]
)
