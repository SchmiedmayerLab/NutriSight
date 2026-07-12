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


extension WearablesCoordinator {
    func performStartCamera() async throws {
        if selectedSource == .phoneCamera {
            try await phoneCamera?.start()
            updateState(.streaming)
            return
        }
        try await ensureRegisteredDevice()
        guard try await wearables.checkPermissionStatus(.camera) == .granted else {
            updateState(.permissionRequired)
            throw WearablesCameraError.permissionRequired
        }
        if let stream, stream.state == .streaming {
            updateState(.streaming)
            return
        }
        guard let sessionManager else {
            throw WearablesCameraError.sessionUnavailable
        }

        updateState(.connecting)
        await stopCamera(keepDeviceSession: true)
        updateState(.connecting)

        do {
            let session = try await sessionManager.readySession()
            let configuration = StreamConfiguration(videoCodec: .raw, resolution: .low, frameRate: 24)
            guard let newStream = try session.addStream(config: configuration) else {
                throw WearablesCameraError.streamUnavailable
            }
            stream = newStream
            installStreamListeners(newStream)
            try await startStream(newStream)
        } catch let error as WearablesCameraError {
            updateState(.paused)
            throw error
        } catch DeviceSessionError.datAppOnTheGlassesUpdateRequired {
            updateRequiredUpdate(.glassesApp)
            updateState(.paused)
            throw WearablesCameraError.deviceUpdateRequired
        } catch {
            updateState(.paused)
            throw WearablesCameraError.sdk(error.localizedDescription)
        }
    }

    func installStreamListeners(_ stream: MWDATCamera.Stream) {
        clearStreamListeners()
        let stateToken = stream.statePublisher.listen { [weak self] streamState in
            Task { @MainActor [weak self] in
                self?.streamStateDidChange(streamState)
            }
        }
        let frameToken = stream.videoFramePublisher.listen { [weak self] frame in
            let image = frame.makeUIImage()
            Task { @MainActor [weak self] in
                self?.updatePreviewImage(image)
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
        streamListenerTokens = [stateToken, frameToken, photoToken, errorToken]
    }

    func streamStateDidChange(_ streamState: StreamState) {
        switch streamState {
        case .streaming:
            resumeCameraStart(with: .success(()))
            if LaunchConfiguration.simulatesCameraPause && !hasSimulatedPause {
                hasSimulatedPause = true
                updateState(.paused)
            } else {
                updateState(.streaming)
            }
        case .paused:
            updateState(.paused)
        case .starting, .waitingForDevice:
            updateState(.connecting)
        case .stopped, .stopping:
            resumeCameraStart(with: .failure(WearablesCameraError.streamUnavailable))
            stream = nil
            updatePreviewImage(nil)
            clearStreamListeners()
            sessionManager?.stopCurrentSession()
            synchronizeDeviceState()
        }
    }

    func receivePhoto(_ data: Data) {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        guard let captureContinuation else {
            return
        }
        self.captureContinuation = nil
        captureContinuation.resume(returning: data)
    }

    func receiveStreamError(_ description: String) {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        if let captureContinuation {
            self.captureContinuation = nil
            captureContinuation.resume(throwing: WearablesCameraError.sdk(description))
        }
        resumeCameraStart(with: .failure(WearablesCameraError.sdk(description)))
        updateState(.paused)
    }

    func stopCamera(keepDeviceSession: Bool) async {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        cameraStartTimeoutTask?.cancel()
        cameraStartTimeoutTask = nil
        let activeStream = stream
        stream = nil
        updatePreviewImage(nil)
        captureContinuation?.resume(throwing: CancellationError())
        captureContinuation = nil
        cameraStartContinuation?.resume(throwing: CancellationError())
        cameraStartContinuation = nil

        let tokens = streamListenerTokens
        streamListenerTokens.removeAll()
        for token in tokens {
            await token.cancel()
        }
        activeStream?.stop()
        if !keepDeviceSession {
            sessionManager?.stopCurrentSession()
        }
        synchronizeDeviceState()
    }

    func startStream(_ stream: MWDATCamera.Stream, timeout: Duration = .seconds(20)) async throws {
        guard cameraStartContinuation == nil else {
            throw WearablesCameraError.sessionUnavailable
        }
        try await withCheckedThrowingContinuation { continuation in
            cameraStartContinuation = continuation
            cameraStartTimeoutTask = Task { [weak self] in
                try? await Task.sleep(for: timeout)
                guard !Task.isCancelled, let self, cameraStartContinuation != nil else {
                    return
                }
                resumeCameraStart(with: .failure(WearablesCameraError.sessionUnavailable))
            }
            stream.start()
            if stream.state == .streaming {
                resumeCameraStart(with: .success(()))
            }
        }
    }

    func resumeCameraStart(with result: Result<Void, any Error>) {
        cameraStartTimeoutTask?.cancel()
        cameraStartTimeoutTask = nil
        guard let cameraStartContinuation else {
            return
        }
        self.cameraStartContinuation = nil
        cameraStartContinuation.resume(with: result)
    }

    func clearStreamListeners() {
        let tokens = streamListenerTokens
        streamListenerTokens.removeAll()
        Task { @concurrent in
            for token in tokens {
                await token.cancel()
            }
        }
    }
}
