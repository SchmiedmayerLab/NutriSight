//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MWDATCamera
import MWDATCore
import Observation
import SwiftUI


@MainActor
@Observable
final class WearablesCamera {
    private let providedWearables: (any WearablesInterface)?
    private var session: DeviceSession?
    private var stream: MWDATCamera.Stream?
    private var wearablesListenerTokens: [any AnyListenerToken] = []
    private var deviceListenerTokens: [any AnyListenerToken] = []
    private var streamListenerTokens: [any AnyListenerToken] = []
    private var observedDeviceIdentifier: DeviceIdentifier?
    private var captureContinuation: CheckedContinuation<Data, any Error>?
    private var captureTimeoutTask: Task<Void, Never>?
    private var hasSimulatedPause = false

    private(set) var state: WearablesCameraState = .notRegistered
    private(set) var deviceName: String?
    private(set) var previewImage: UIImage?

    private var wearables: any WearablesInterface {
        providedWearables ?? Wearables.shared
    }

    init(wearables: (any WearablesInterface)? = nil) {
        self.providedWearables = wearables
    }

    func start() {
        installWearablesListeners()
        refresh()
    }

    func refresh() {
        guard wearables.registrationState == .registered else {
            state = .notRegistered
            deviceName = nil
            clearObservedDevice()
            return
        }
        updateDevices(wearables.devices)
    }

    func register() async throws {
        try await wearables.startRegistration()
        refresh()
    }

    func handle(_ url: URL) async throws {
        _ = try await wearables.handleUrl(url)
        refresh()
    }

    func connect() async throws {
        if let stream, stream.state == .streaming {
            state = .streaming
            return
        }
        guard let device = wearables.devices.first else {
            throw WearablesCameraError.noDevice
        }

        let currentPermission = try await wearables.checkPermissionStatus(.camera)
        let permission = if currentPermission == .granted {
            currentPermission
        } else {
            try await wearables.requestPermission(.camera)
        }
        guard permission == .granted else {
            throw WearablesCameraError.permissionDenied
        }

        await stopSession()
        state = .connecting

        do {
            let selector = SpecificDeviceSelector(device: device)
            let session = try wearables.createSession(deviceSelector: selector)
            self.session = session
            try await start(session)

            let configuration = StreamConfiguration(videoCodec: .raw, resolution: .low, frameRate: 24)
            guard let stream = try session.addStream(config: configuration) else {
                throw WearablesCameraError.streamUnavailable
            }
            self.stream = stream
            installStreamListeners(stream)
            stream.start()
        } catch let error as WearablesCameraError {
            throw error
        } catch {
            state = .ready
            throw WearablesCameraError.sdk(error.localizedDescription)
        }
    }

    private func start(_ session: DeviceSession) async throws {
        let stateStream = session.stateStream()
        let errorStream = session.errorStream()
        try session.start()
        guard session.state != .started else {
            return
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                for await state in stateStream {
                    if state == .started {
                        return
                    }
                    if state == .stopped {
                        throw WearablesCameraError.sessionUnavailable
                    }
                }
                throw WearablesCameraError.sessionUnavailable
            }
            group.addTask {
                for await error in errorStream {
                    throw error
                }
                throw WearablesCameraError.sessionUnavailable
            }
            _ = try await group.next()
            group.cancelAll()
        }
    }

    func capturePhoto(timeout: Duration = .seconds(20)) async throws -> Data {
        guard let stream, stream.state == .streaming else {
            throw WearablesCameraError.streamNotReady
        }
        guard captureContinuation == nil else {
            throw WearablesCameraError.captureRejected
        }

        return try await withCheckedThrowingContinuation { continuation in
            captureContinuation = continuation
            guard stream.capturePhoto(format: .jpeg) else {
                captureContinuation = nil
                continuation.resume(throwing: WearablesCameraError.captureRejected)
                return
            }
            captureTimeoutTask = Task { [weak self] in
                try? await Task.sleep(for: timeout)
                guard !Task.isCancelled, let self, let continuation = self.captureContinuation else {
                    return
                }
                self.captureContinuation = nil
                self.captureTimeoutTask = nil
                continuation.resume(throwing: WearablesCameraError.captureTimedOut)
            }
        }
    }

    func stopSession() async {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        stream?.stop()
        session?.stop()
        stream = nil
        session = nil
        previewImage = nil
        captureContinuation?.resume(throwing: CancellationError())
        captureContinuation = nil

        let tokens = streamListenerTokens
        streamListenerTokens.removeAll()
        for token in tokens {
            await token.cancel()
        }
        refresh()
    }
}


extension WearablesCamera {
    private func installWearablesListeners() {
        guard wearablesListenerTokens.isEmpty else {
            return
        }
        let registrationToken = wearables.addRegistrationStateListener { [weak self] registrationState in
            let rawValue = registrationState.rawValue
            Task { @MainActor [weak self] in
                guard let registrationState = RegistrationState(rawValue: rawValue) else {
                    return
                }
                self?.registrationDidChange(registrationState)
            }
        }
        let devicesToken = wearables.addDevicesListener { [weak self] devices in
            Task { @MainActor [weak self] in
                self?.updateDevices(devices)
            }
        }
        wearablesListenerTokens.append(contentsOf: [registrationToken, devicesToken])
    }

    private func installStreamListeners(_ stream: MWDATCamera.Stream) {
        let stateToken = stream.statePublisher.listen { [weak self] streamState in
            Task { @MainActor [weak self] in
                self?.streamStateDidChange(streamState)
            }
        }
        let frameToken = stream.videoFramePublisher.listen { [weak self] frame in
            let image = frame.makeUIImage()
            Task { @MainActor [weak self] in
                self?.previewImage = image
            }
        }
        let photoToken = stream.photoDataPublisher.listen { [weak self] photo in
            Task { @MainActor [weak self] in
                self?.receivePhoto(photo.data)
            }
        }
        let errorToken = stream.errorPublisher.listen { [weak self] error in
            let description = error.localizedDescription
            Task { @MainActor [weak self] in
                self?.receiveStreamError(description)
            }
        }
        streamListenerTokens.append(contentsOf: [stateToken, frameToken, photoToken, errorToken])
    }

    private func registrationDidChange(_ registrationState: RegistrationState) {
        if registrationState == .registered {
            updateDevices(wearables.devices)
        } else {
            state = .notRegistered
            deviceName = nil
            clearObservedDevice()
        }
    }

    private func updateDevices(_ devices: [DeviceIdentifier]) {
        guard wearables.registrationState == .registered else {
            state = .notRegistered
            deviceName = nil
            clearObservedDevice()
            return
        }
        guard let identifier = devices.first else {
            state = .noDevice
            deviceName = nil
            clearObservedDevice()
            return
        }
        guard let device = wearables.deviceForIdentifier(identifier) else {
            state = .noDevice
            deviceName = nil
            clearObservedDevice()
            return
        }
        observe(device)
        deviceName = device.nameOrId()
        if stream == nil {
            state = if device.linkState == .connected && device.compatibility() == .compatible {
                .ready
            } else {
                .connecting
            }
        }
    }

    private func observe(_ device: Device) {
        guard observedDeviceIdentifier != device.identifier else {
            return
        }
        clearObservedDevice()
        observedDeviceIdentifier = device.identifier

        let linkToken = device.addLinkStateListener { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        let compatibilityToken = device.addCompatibilityListener { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        deviceListenerTokens.append(contentsOf: [linkToken, compatibilityToken])
    }

    private func clearObservedDevice() {
        observedDeviceIdentifier = nil
        let tokens = deviceListenerTokens
        deviceListenerTokens.removeAll()
        Task {
            for token in tokens {
                await token.cancel()
            }
        }
    }

    private func streamStateDidChange(_ streamState: StreamState) {
        switch streamState {
        case .streaming:
            if LaunchConfiguration.simulatesCameraPause && !hasSimulatedPause {
                hasSimulatedPause = true
                state = .paused
            } else {
                state = .streaming
            }
        case .paused:
            state = .paused
        case .starting, .waitingForDevice:
            state = .connecting
        case .stopped, .stopping:
            if wearables.devices.isEmpty {
                state = .noDevice
            } else {
                state = .ready
            }
        }
    }

    private func receivePhoto(_ data: Data) {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        guard let captureContinuation else {
            return
        }
        self.captureContinuation = nil
        captureContinuation.resume(returning: data)
    }

    private func receiveStreamError(_ description: String) {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        if let captureContinuation {
            self.captureContinuation = nil
            captureContinuation.resume(throwing: WearablesCameraError.sdk(description))
        }
        state = .paused
    }
}


extension WearablesCamera {
    convenience init(previewImage: UIImage?, state: WearablesCameraState = .streaming) {
        self.init()
        self.previewImage = previewImage
        self.state = state
    }
}
