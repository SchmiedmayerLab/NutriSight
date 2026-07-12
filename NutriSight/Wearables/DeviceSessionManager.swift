//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MWDATCore
import Observation


/// Owns active-device selection and the one-to-one lifecycle of a Meta `DeviceSession`.
///
/// This type deliberately does not request permissions or create camera streams. Callers ask for a ready session only
/// when they are prepared to use one, which prevents device discovery from racing eager session creation.
@MainActor
@Observable
final class DeviceSessionManager {
    private(set) var state: DeviceSessionManagerState = .noDevice
    private(set) var isSessionReady = false

    @ObservationIgnored var stateDidChange: (@MainActor () -> Void)?

    @ObservationIgnored private let wearables: any WearablesInterface
    @ObservationIgnored private let deviceSelector: AutoDeviceSelector
    @ObservationIgnored private var session: DeviceSession?
    @ObservationIgnored private var activeDeviceIdentifier: DeviceIdentifier?
    @ObservationIgnored private var deviceMonitorTask: Task<Void, Never>?
    @ObservationIgnored private var sessionStateTask: Task<Void, Never>?
    @ObservationIgnored private var deviceListenerTokens: [any AnyListenerToken] = []

    var hasActiveDevice: Bool {
        activeDeviceIdentifier != nil
    }

    init(wearables: any WearablesInterface) {
        self.wearables = wearables
        self.deviceSelector = AutoDeviceSelector(wearables: wearables)
        startMonitoringDevices()
    }

    func refresh() {
        activeDeviceDidChange(deviceSelector.activeDevice)
    }

    /// Lazily returns the session for the currently selected device after it reaches its started state.
    func readySession() async throws -> DeviceSession {
        guard activeDeviceIdentifier != nil else {
            throw WearablesCameraError.noDevice
        }

        if let session, session.state == .started {
            updateSessionReadiness(true)
            return session
        }

        if session?.state == .stopped {
            session = nil
        }

        if let session {
            try await waitUntilStarted(session)
            observeSessionState(session)
            updateSessionReadiness(true)
            return session
        }

        do {
            let newSession = try wearables.createSession(deviceSelector: deviceSelector)
            session = newSession
            let stateStream = newSession.stateStream()
            let errorStream = newSession.errorStream()
            try newSession.start()

            if newSession.state != .started {
                try await waitUntilStarted(stateStream: stateStream, errorStream: errorStream)
            }
            observeSessionState(newSession)
            updateSessionReadiness(true)
            return newSession
        } catch {
            session = nil
            updateSessionReadiness(false)
            throw error
        }
    }

    func stopCurrentSession() {
        sessionStateTask?.cancel()
        sessionStateTask = nil
        session?.stop()
        session = nil
        updateSessionReadiness(false)
    }

    func cleanup() async {
        deviceMonitorTask?.cancel()
        deviceMonitorTask = nil
        stopCurrentSession()
        activeDeviceIdentifier = nil
        let tokens = deviceListenerTokens
        deviceListenerTokens.removeAll()
        for token in tokens {
            await token.cancel()
        }
        updateState(.noDevice)
    }

    private func startMonitoringDevices() {
        deviceMonitorTask?.cancel()
        deviceMonitorTask = Task { [weak self] in
            guard let self else {
                return
            }
            for await identifier in deviceSelector.activeDeviceStream() {
                guard !Task.isCancelled else {
                    return
                }
                activeDeviceDidChange(identifier)
            }
        }
    }

    private func activeDeviceDidChange(_ identifier: DeviceIdentifier?) {
        guard identifier != activeDeviceIdentifier else {
            evaluateActiveDevice()
            return
        }

        stopCurrentSession()
        clearDeviceListeners()
        activeDeviceIdentifier = identifier
        guard let identifier else {
            updateState(wearables.devices.isEmpty ? .noDevice : .selectingDevice)
            return
        }
        guard let device = wearables.deviceForIdentifier(identifier) else {
            updateState(.selectingDevice)
            return
        }

        let linkToken = device.addLinkStateListener { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.evaluateActiveDevice()
            }
        }
        let compatibilityToken = device.addCompatibilityListener { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.evaluateActiveDevice()
            }
        }
        deviceListenerTokens = [linkToken, compatibilityToken]
        evaluateActiveDevice()
    }

    private func evaluateActiveDevice() {
        guard let activeDeviceIdentifier,
              let device = wearables.deviceForIdentifier(activeDeviceIdentifier) else {
            updateState(wearables.devices.isEmpty ? .noDevice : .selectingDevice)
            return
        }

        let name = device.nameOrId()
        let compatibility = device.compatibility()
        if compatibility == .deviceUpdateRequired {
            updateState(.updateRequired(deviceName: name))
        } else if compatibility != .compatible {
            updateState(.incompatible(deviceName: name))
        } else if device.linkState == .connected {
            updateState(.ready(deviceName: name))
        } else {
            updateState(.connecting(deviceName: name))
        }
    }

    private func waitUntilStarted(_ session: DeviceSession) async throws {
        if session.state == .started {
            return
        }
        try await waitUntilStarted(stateStream: session.stateStream(), errorStream: session.errorStream())
    }

    private func waitUntilStarted(
        stateStream: AsyncStream<DeviceSessionState>,
        errorStream: AsyncStream<DeviceSessionError>
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for await state in stateStream {
                    try Task.checkCancellation()
                    if state == .started {
                        return
                    }
                    if state == .stopped {
                        throw WearablesCameraError.sessionUnavailable
                    }
                }
                try Task.checkCancellation()
                throw WearablesCameraError.sessionUnavailable
            }
            group.addTask {
                for await error in errorStream {
                    try Task.checkCancellation()
                    throw error
                }
                try Task.checkCancellation()
                throw WearablesCameraError.sessionUnavailable
            }
            guard try await group.next() != nil else {
                throw WearablesCameraError.sessionUnavailable
            }
            group.cancelAll()
        }
    }

    private func observeSessionState(_ session: DeviceSession) {
        sessionStateTask?.cancel()
        sessionStateTask = Task { [weak self] in
            for await sessionState in session.stateStream() {
                guard !Task.isCancelled, let self else {
                    return
                }
                if sessionState == .started {
                    updateSessionReadiness(true)
                } else if sessionState == .stopped {
                    self.session = nil
                    updateSessionReadiness(false)
                    evaluateActiveDevice()
                    return
                } else {
                    updateSessionReadiness(false)
                }
            }
        }
    }

    private func updateState(_ newState: DeviceSessionManagerState) {
        guard state != newState else {
            return
        }
        state = newState
        stateDidChange?()
    }

    private func updateSessionReadiness(_ ready: Bool) {
        guard isSessionReady != ready else {
            return
        }
        isSessionReady = ready
        stateDidChange?()
    }

    private func clearDeviceListeners() {
        let tokens = deviceListenerTokens
        deviceListenerTokens.removeAll()
        Task { @concurrent in
            for token in tokens {
                await token.cancel()
            }
        }
    }

    isolated deinit {
        deviceMonitorTask?.cancel()
        sessionStateTask?.cancel()
        session?.stop()
    }
}
