// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FENRVCUEmulator",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ActivityFeature", targets: ["ActivityFeature"]),
        .library(name: "FailuresFeature", targets: ["FailuresFeature"]),
        .library(name: "ConfigurationFeature", targets: ["ConfigurationFeature"]),
        .library(name: "SimulationFeature", targets: ["SimulationFeature"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "EmulatorDomain", targets: ["EmulatorDomain"]),
        .library(name: "EmulatorData", targets: ["EmulatorData"]),
        .library(name: "ProtocolCore", targets: ["ProtocolCore"]),
        .library(name: "VehicleSimulation", targets: ["VehicleSimulation"]),
        .library(name: "ProtocolEngine", targets: ["ProtocolEngine"]),
        .library(name: "BLEPeripheral", targets: ["BLEPeripheral"])
    ],
    targets: [
        .target(name: "ActivityFeature", dependencies: ["EmulatorDomain", "DesignSystem"], path: "Features/Activity", exclude: ["Tests"], sources: ["Sources"], resources: [.process("Resources")]),
        .testTarget(name: "ActivityFeatureTests", dependencies: ["ActivityFeature"], path: "Features/Activity/Tests"),
        .target(name: "FailuresFeature", dependencies: ["EmulatorDomain", "DesignSystem"], path: "Features/Failures", exclude: ["Tests"], sources: ["Sources"], resources: [.process("Resources")]),
        .testTarget(name: "FailuresFeatureTests", dependencies: ["FailuresFeature"], path: "Features/Failures/Tests"),
        .target(name: "ConfigurationFeature", dependencies: ["EmulatorDomain", "DesignSystem"], path: "Features/Configuration", exclude: ["Tests"], sources: ["Sources"], resources: [.process("Resources")]),
        .testTarget(name: "ConfigurationFeatureTests", dependencies: ["ConfigurationFeature"], path: "Features/Configuration/Tests"),
        .target(name: "SimulationFeature", dependencies: ["EmulatorDomain", "DesignSystem"], path: "Features/Simulation", exclude: ["Tests"], sources: ["Sources"], resources: [.process("Resources")]),
        .testTarget(name: "SimulationFeatureTests", dependencies: ["SimulationFeature"], path: "Features/Simulation/Tests"),
        .target(name: "DesignSystem", path: "Modules/DesignSystem/Sources"),
        .testTarget(name: "EmulatorDataTests", dependencies: ["EmulatorData"], path: "Modules/EmulatorData/Tests"),
        .target(name: "EmulatorDomain", dependencies: ["VehicleSimulation", "ProtocolEngine"], path: "Modules/EmulatorDomain/Sources"),
        .target(name: "EmulatorData", dependencies: ["EmulatorDomain", "BLEPeripheral"], path: "Modules/EmulatorData/Sources"),
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
