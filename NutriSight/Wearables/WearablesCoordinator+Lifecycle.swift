//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MWDATCore


extension WearablesCoordinator {
    static func cameraState(for deviceState: DeviceSessionManagerState) -> WearablesCameraState {
        switch deviceState {
        case .noDevice:
            .noDevice
        case .selectingDevice, .connecting:
            .connecting
        case .ready:
            .ready
        case .updateRequired, .incompatible:
            .paused
        }
    }

    func activateMetaLifecycle() {
        if sessionManager == nil {
            let manager = DeviceSessionManager(wearables: wearables)
            manager.stateDidChange = { [weak self] in
                self?.synchronizeDeviceState()
            }
            sessionManager = manager
        }
        guard registrationTask == nil else {
            return
        }
        registrationTask = Task { [weak self] in
            guard let self else {
                return
            }
            for await registrationState in wearables.registrationStateStream() {
                guard !Task.isCancelled else {
                    return
                }
                registrationDidChange(registrationState)
            }
        }
    }

    func ensureMetaSourceSelected() async throws {
        if selectedSource == nil {
            try await selectSource(.metaGlasses)
        }
        guard selectedSource == .metaGlasses || selectedSource == .simulatedGlasses else {
            throw WearablesCameraError.sessionUnavailable
        }
        activateMetaLifecycle()
    }

    func ensureRegisteredDevice() async throws {
        try await ensureMetaSourceSelected()
        guard wearables.registrationState == .registered else {
            updateState(.notRegistered)
            throw WearablesCameraError.registrationRequired
        }
        refreshDevices()
        guard let sessionManager else {
            throw WearablesCameraError.sessionUnavailable
        }
        switch sessionManager.state {
        case .noDevice, .selectingDevice:
            updateState(.noDevice)
            throw WearablesCameraError.noDevice
        case .connecting:
            updateState(.connecting)
            throw WearablesCameraError.noDevice
        case .updateRequired:
            updateRequiredUpdate(.glassesFirmware)
            throw WearablesCameraError.deviceUpdateRequired
        case .incompatible:
            throw WearablesCameraError.incompatibleDevice
        case .ready:
            return
        }
    }

    func registrationDidChange(_ registrationState: RegistrationState) {
        switch registrationState {
        case .registered:
            refreshDevices()
        case .registering:
            updateState(.connecting)
        case .available, .unavailable:
            updateState(.notRegistered)
            updateDeviceName(nil)
            updateRequiredUpdate(nil)
            Task { [weak self] in
                await self?.stopCamera()
            }
        }
        publishStatus()
    }

    func synchronizeDeviceState() {
        guard selectedSource == .metaGlasses || selectedSource == .simulatedGlasses else {
            return
        }
        guard wearables.registrationState == .registered, let sessionManager else {
            return
        }
        updateDeviceName(sessionManager.state.deviceName)
        switch sessionManager.state {
        case .updateRequired:
            updateRequiredUpdate(.glassesFirmware)
        case .incompatible:
            updateRequiredUpdate(.application)
        case .noDevice, .selectingDevice, .connecting, .ready:
            updateRequiredUpdate(nil)
        }
        guard stream == nil else {
            return
        }
        updateState(Self.cameraState(for: sessionManager.state))
    }

    func deactivateMetaLifecycle() async {
        registrationTask?.cancel()
        registrationTask = nil
        if let sessionManager {
            await sessionManager.cleanup()
        }
        sessionManager = nil
        updateRequiredUpdate(nil)
        updateDeviceName(nil)
    }

    func publishStatus() {
        guard !statusContinuations.isEmpty else {
            return
        }
        let snapshot = status
        for continuation in statusContinuations.values {
            continuation.yield(snapshot)
        }
    }
}
