//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import UIKit


/// Owns the complete AVFoundation session lifecycle on ``PhoneCameraSessionActor``.
@PhoneCameraSessionActor
final class PhoneCameraSession: NSObject {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "edu.stanford.nutrisight.phone-camera.video", qos: .userInitiated)
    nonisolated private let previewHandler: @MainActor @Sendable (UIImage) -> Void

    private var isConfigured = false
    private var captureContinuation: CheckedContinuation<Data, any Error>?
    private var captureTimeoutTask: Task<Void, Never>?

    init(previewHandler: @escaping @MainActor @Sendable (UIImage) -> Void) {
        self.previewHandler = previewHandler
        super.init()
    }

    func start() -> Bool {
        configureIfNeeded()
        guard isConfigured else {
            return false
        }
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        return captureSession.isRunning
    }

    func capturePhoto(timeout: Duration) async throws -> Data {
        guard captureSession.isRunning else {
            throw WearablesCameraError.streamNotReady
        }
        guard captureContinuation == nil else {
            throw WearablesCameraError.captureRejected
        }

        return try await withCheckedThrowingContinuation { continuation in
            captureContinuation = continuation
            captureTimeoutTask = Task { @PhoneCameraSessionActor [weak self] in
                try? await Task.sleep(for: timeout)
                guard !Task.isCancelled, let self else {
                    return
                }
                self.completeCapture(with: .failure(WearablesCameraError.captureTimedOut))
            }
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }

    func stop() {
        completeCapture(with: .failure(CancellationError()))
        if captureSession.isRunning {
            captureSession.stopRunning()
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
            guard captureSession.canAddInput(input),
                  captureSession.canAddOutput(photoOutput),
                  captureSession.canAddOutput(videoOutput) else {
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


extension PhoneCameraSession: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: (any Error)?
    ) {
        let result: Result<Data, any Error>
        if let error {
            result = .failure(WearablesCameraError.sdk(error.localizedDescription))
        } else if let data = photo.fileDataRepresentation() {
            result = .success(data)
        } else {
            result = .failure(WearablesCameraError.captureRejected)
        }

        Task { @PhoneCameraSessionActor [weak self] in
            self?.completeCapture(with: result)
        }
    }
}


extension PhoneCameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
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
        Task { @MainActor [previewHandler] in
            previewHandler(image)
        }
    }
}
