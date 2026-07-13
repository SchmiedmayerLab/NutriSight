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
import Spezi
import SwiftUI


/// High-level lifecycle API for registration, camera permission, device connectivity, streaming, and photo capture.
///
/// Views and feature models should interact with this coordinator rather than with DAT SDK sessions or streams.
/// `DeviceSessionManager` is the only type that owns a Meta `DeviceSession`, keeping this boundary suitable for a
/// future package extraction.
@MainActor
@Observable
final class WearablesCoordinator: Module, EnvironmentAccessible {
    @ObservationIgnored let providedWearables: (any WearablesInterface)?
    @ObservationIgnored var sessionManager: DeviceSessionManager?
    @ObservationIgnored var registrationTask: Task<Void, Never>?
    @ObservationIgnored var stream: MWDATCamera.Stream?
    @ObservationIgnored var streamListenerTokens: [any AnyListenerToken] = []
    @ObservationIgnored var captureContinuation: CheckedContinuation<Data, any Error>?
    @ObservationIgnored var captureTimeoutTask: Task<Void, Never>?
    @ObservationIgnored var cameraStartContinuation: CheckedContinuation<Void, any Error>?
    @ObservationIgnored var cameraStartTimeoutTask: Task<Void, Never>?
    @ObservationIgnored var cameraStartTask: Task<Void, any Error>?
    @ObservationIgnored var phoneCamera: PhoneCamera?
    @ObservationIgnored var statusContinuations: [UUID: AsyncStream<WearablesStatus>.Continuation] = [:]
    @ObservationIgnored var hasSimulatedPause = false

    private(set) var selectedSource: GlassesSource? {
        didSet {
            publishStatus()
        }
    }
    private(set) var state: WearablesCameraState = .notRegistered {
        didSet {
            guard oldValue != state else {
                return
            }
            publishStatus()
        }
    }
    private(set) var deviceName: String? {
        didSet {
            guard oldValue != deviceName else {
                return
            }
            publishStatus()
        }
    }
    private(set) var previewImage: UIImage?
    private(set) var requiredUpdate: WearablesRequiredUpdate? {
        didSet {
            guard oldValue != requiredUpdate else {
                return
            }
            publishStatus()
        }
    }

    var wearables: any WearablesInterface {
        providedWearables ?? Wearables.shared
    }

    var canCapture: Bool {
        state == .streaming || phoneCamera?.isAvailable == true
    }

    var isRegistered: Bool {
        switch selectedSource {
        case .metaGlasses, .simulatedGlasses:
            wearables.registrationState == .registered
        case .phoneCamera:
            true
        case nil:
            false
        }
    }

    var status: WearablesStatus {
        WearablesStatus(
            source: selectedSource,
            state: state,
            deviceName: deviceName,
            isRegistered: isRegistered,
            requiredUpdate: requiredUpdate,
            canCapture: canCapture
        )
    }

    init(wearables: (any WearablesInterface)? = nil) {
        self.providedWearables = wearables
        self.selectedSource = nil
        self.requiredUpdate = nil
        self.phoneCamera = PhoneCamera { [weak self] image in
            guard let self, stream?.state != .streaming else {
                return
            }
            previewImage = image
            state = .streaming
        }
    }

    /// Selects and prepares a camera source. Repeated calls for the active source repair its listeners and state.
    func selectSource(_ source: GlassesSource?) async throws {
        if selectedSource != nil && selectedSource != source {
            await stopCamera()
            await phoneCamera?.stop()
            await deactivateMetaLifecycle()
        }
        guard let source else {
            selectedSource = nil
            state = .notRegistered
            return
        }
        try WearablesBootstrap.configure(using: source)
        selectedSource = source

        switch source {
        case .phoneCamera:
            try await phoneCamera?.start()
            state = .streaming
        case .metaGlasses, .simulatedGlasses:
            activateMetaLifecycle()
            refreshDevices()
        }
    }

    /// Starts or repairs Meta registration. SDK configuration and registration observation are automatic.
    func pair() async throws {
        try await ensureMetaSourceSelected()
        guard wearables.registrationState != .registered else {
            refreshDevices()
            return
        }
        try await wearables.startRegistration()
        if wearables.registrationState == .registered {
            refreshDevices()
        } else {
            state = .connecting
        }
    }

    // periphery:ignore - Public API for clients that expose device-management controls outside this app's UI.
    func unpair() async throws {
        try await ensureMetaSourceSelected()
        try await wearables.startUnregistration()
        await stopCamera()
        state = .notRegistered
        deviceName = nil
    }

    func handleRegistrationCallback(_ url: URL) async throws {
        try await ensureMetaSourceSelected()
        _ = try await wearables.handleUrl(url)
        refreshDevices()
    }

    func cameraAccessIsGranted() async throws -> Bool {
        try await ensureRegisteredDevice()
        return try await wearables.checkPermissionStatus(.camera) == .granted
    }

    func requestCameraAccess() async throws {
        try await ensureRegisteredDevice()
        let currentPermission = try await wearables.checkPermissionStatus(.camera)
        let resultingPermission = if currentPermission == .granted {
            currentPermission
        } else {
            try await wearables.requestPermission(.camera)
        }
        guard resultingPermission == .granted else {
            state = .permissionRequired
            throw WearablesCameraError.permissionDenied
        }
        refreshDevices()
    }

    /// Enforces source setup, registration, device compatibility, and permission before starting the camera.
    func startCamera() async throws {
        if let cameraStartTask {
            try await cameraStartTask.value
            return
        }
        let task = Task<Void, any Error> { @MainActor [weak self] in
            guard let self else {
                throw CancellationError()
            }
            try await performStartCamera()
        }
        cameraStartTask = task
        defer {
            cameraStartTask = nil
        }
        try await task.value
    }

    func capturePhoto(timeout: Duration = .seconds(20)) async throws -> Data {
        if state != .streaming && selectedSource != .phoneCamera {
            try await startCamera()
        }
        guard let stream, stream.state == .streaming else {
            guard let phoneCamera else {
                throw WearablesCameraError.streamNotReady
            }
            return try await phoneCamera.capturePhoto(timeout: timeout)
        }
        guard captureContinuation == nil else {
            throw WearablesCameraError.captureRejected
        }
        let simulatedCaptureFallbackData = simulatedCaptureFallbackData()
        let captureTimeout = simulatedCaptureFallbackData == nil ? timeout : .seconds(2)

        return try await withCheckedThrowingContinuation { continuation in
            captureContinuation = continuation
            guard stream.capturePhoto(format: .jpeg) else {
                captureContinuation = nil
                continuation.resume(throwing: WearablesCameraError.captureRejected)
                return
            }
            captureTimeoutTask = Task { [weak self] in
                try? await Task.sleep(for: captureTimeout)
                guard !Task.isCancelled, let self, let continuation = captureContinuation else {
                    return
                }
                captureContinuation = nil
                captureTimeoutTask = nil
                if let simulatedCaptureFallbackData {
                    continuation.resume(returning: simulatedCaptureFallbackData)
                    return
                }
                continuation.resume(throwing: WearablesCameraError.captureTimedOut)
                await recoverCameraAfterCaptureTimeout()
            }
        }
    }

    func refreshDevices() {
        guard selectedSource == .metaGlasses || selectedSource == .simulatedGlasses else {
            if selectedSource == nil {
                state = .notRegistered
            }
            return
        }
        guard wearables.registrationState == .registered else {
            state = .notRegistered
            deviceName = nil
            requiredUpdate = nil
            sessionManager?.stopCurrentSession()
            return
        }
        sessionManager?.refresh()
        synchronizeDeviceState()
    }

    func stopCamera() async {
        cameraStartTask?.cancel()
        cameraStartTask = nil
        await stopCamera(keepDeviceSession: false)
    }

    /// Produces current and future status snapshots with only the newest buffered value.
    func statusUpdates() -> AsyncStream<WearablesStatus> {
        let identifier = UUID()
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            statusContinuations[identifier] = continuation
            continuation.yield(status)
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.statusContinuations[identifier] = nil
                }
            }
        }
    }

    isolated deinit {
        registrationTask?.cancel()
        captureTimeoutTask?.cancel()
        cameraStartTimeoutTask?.cancel()
        cameraStartTask?.cancel()
        stream?.stop()
        captureContinuation?.resume(throwing: CancellationError())
        cameraStartContinuation?.resume(throwing: CancellationError())
        for continuation in statusContinuations.values {
            continuation.finish()
        }
    }
}


extension WearablesCoordinator {
    func updateState(_ newState: WearablesCameraState) {
        state = newState
    }

    func updateDeviceName(_ newDeviceName: String?) {
        deviceName = newDeviceName
    }

    func updatePreviewImage(_ image: UIImage?) {
        previewImage = image
    }

    func updateRequiredUpdate(_ update: WearablesRequiredUpdate?) {
        requiredUpdate = update
    }
}


extension WearablesCoordinator {
    // periphery:ignore - Creates states used exclusively by `#Preview` declarations, which Periphery cannot trace.
    convenience init(
        previewImage: UIImage?,
        state: WearablesCameraState = .streaming,
        source: GlassesSource? = nil
    ) {
        self.init()
        self.previewImage = previewImage
        self.state = state
        self.selectedSource = source
    }
}
