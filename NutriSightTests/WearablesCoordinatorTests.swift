//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import NutriSight
import Spezi
import Testing


@MainActor
@Suite("Wearables coordinator")
struct WearablesCoordinatorTests {
    @Test("Provides an initial async status snapshot as a Spezi module")
    func providesInitialStatus() async throws {
        let coordinator = WearablesCoordinator()
        let module: any Module = coordinator
        var updates = coordinator.statusUpdates().makeAsyncIterator()
        let status = try #require(await updates.next())

        #expect(module is WearablesCoordinator)
        #expect(status == WearablesStatus(
            source: nil,
            state: .notRegistered,
            deviceName: nil,
            isRegistered: false,
            requiredUpdate: nil,
            canCapture: false
        ))
    }

    @Test("Allows safe cleanup before the SDK has been configured")
    func allowsCleanupBeforeConfiguration() async throws {
        let coordinator = WearablesCoordinator()

        await coordinator.stopCamera()
        try await coordinator.selectSource(nil)

        #expect(coordinator.status.state == .notRegistered)
        #expect(coordinator.status.source == nil)
    }

    @Test(
        "Maps device lifecycle into camera lifecycle",
        arguments: [
            (DeviceSessionManagerState.noDevice, WearablesCameraState.noDevice),
            (.selectingDevice, .connecting),
            (.connecting(deviceName: "Glasses"), .connecting),
            (.ready(deviceName: "Glasses"), .ready),
            (.updateRequired(deviceName: "Glasses"), .paused),
            (.incompatible(deviceName: "Glasses"), .paused)
        ]
    )
    func mapsDeviceState(deviceState: DeviceSessionManagerState, cameraState: WearablesCameraState) {
        #expect(WearablesCoordinator.cameraState(for: deviceState) == cameraState)
    }

    @Test("Preserves active device names across lifecycle states")
    func preservesDeviceNames() {
        #expect(DeviceSessionManagerState.noDevice.deviceName == nil)
        #expect(DeviceSessionManagerState.selectingDevice.deviceName == nil)
        #expect(DeviceSessionManagerState.connecting(deviceName: "Adventure").deviceName == "Adventure")
        #expect(DeviceSessionManagerState.ready(deviceName: "Adventure").deviceName == "Adventure")
        #expect(DeviceSessionManagerState.updateRequired(deviceName: "Adventure").deviceName == "Adventure")
        #expect(DeviceSessionManagerState.incompatible(deviceName: "Adventure").deviceName == "Adventure")
    }
}
