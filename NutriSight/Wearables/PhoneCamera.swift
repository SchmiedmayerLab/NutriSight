//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import UIKit


@MainActor
final class PhoneCamera: NSObject {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "edu.stanford.nutrisight.phone-camera.video")
    private let previewHandler: @MainActor (UIImage) -> Void

    private var isConfigured = false
    private var captureContinuation: CheckedContinuation<Data, any Error>?
    private var captureTimeoutTask: Task<Void, Never>?

    private(set) var isAvailable = false

    init(previewHandler: @escaping @MainActor (UIImage) -> Void) {
        self.previewHandler = previewHandler
        super.init()
    }

    func start() {
        guard Self.isSupported else {
            return
        }
        Task {
            guard await Self.requestAccess() else {
                return
            }
            configureIfNeeded()
            guard isConfigured, !captureSession.isRunning else {
                isAvailable = isConfigured
                return
            }
            captureSession.startRunning()
            isAvailable = true
        }
    }

    func capturePhoto(timeout: Duration = .seconds(20)) async throws -> Data {
        guard isAvailable else {
            throw WearablesCameraError.streamNotReady
        }
        guard captureContinuation == nil else {
            throw WearablesCameraError.captureRejected
        }

        return try await withCheckedThrowingContinuation { continuation in
            captureContinuation = continuation
            captureTimeoutTask = Task { [weak self] in
                try? await Task.sleep(for: timeout)
                guard !Task.isCancelled, let self, let continuation = self.captureContinuation else {
                    return
                }
                self.captureContinuation = nil
                self.captureTimeoutTask = nil
                continuation.resume(throwing: WearablesCameraError.captureTimedOut)
            }
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }

    func stop() {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        captureContinuation?.resume(throwing: CancellationError())
        captureContinuation = nil
        isAvailable = false
        guard captureSession.isRunning else {
            return
        }
        captureSession.stopRunning()
    }

    static var isSupported: Bool {
        #if targetEnvironment(simulator)
        false
        #else
        true
        #endif
    }

    static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            true
        case .notDetermined:
            await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            false
        @unknown default:
            false
        }
    }

    private func configureIfNeeded() {
        guard !isConfigured else {
            return
        }
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            guard captureSession.canAddInput(input), captureSession.canAddOutput(photoOutput), captureSession.canAddOutput(videoOutput) else {
                return
            }

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .photo
            captureSession.addInput(input)
            captureSession.addOutput(photoOutput)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            captureSession.addOutput(videoOutput)
            captureSession.commitConfiguration()
            isConfigured = true
        } catch {
            isConfigured = false
        }
    }

    private func completeCapture(with result: Result<Data, any Error>) {
        captureTimeoutTask?.cancel()
        captureTimeoutTask = nil
        guard let captureContinuation else {
            return
        }
        self.captureContinuation = nil
        captureContinuation.resume(with: result)
    }
}


extension PhoneCamera: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: (any Error)?
    ) {
        if let error {
            Task { @MainActor [weak self] in
                self?.completeCapture(with: .failure(WearablesCameraError.sdk(error.localizedDescription)))
            }
            return
        }
        guard let data = photo.fileDataRepresentation() else {
            Task { @MainActor [weak self] in
                self?.completeCapture(with: .failure(WearablesCameraError.captureRejected))
            }
            return
        }
        Task { @MainActor [weak self] in
            self?.completeCapture(with: .success(data))
        }
    }
}


extension PhoneCamera: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let context = CIContext()
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        Task { @MainActor [weak self] in
            self?.previewHandler(image)
        }
    }
}
