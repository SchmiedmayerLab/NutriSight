//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import UIKit


/// Main-actor facade for the phone camera and its UI-facing availability state.
@MainActor
final class PhoneCamera {
    static var isSupported: Bool {
        #if targetEnvironment(simulator)
        false
        #else
        true
        #endif
    }

    private let previewHandler: @MainActor @Sendable (UIImage) -> Void
    private var session: PhoneCameraSession?

    private(set) var isAvailable = false

    init(previewHandler: @escaping @MainActor @Sendable (UIImage) -> Void) {
        self.previewHandler = previewHandler
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

    func start() async throws {
        guard Self.isSupported else {
            throw WearablesCameraError.streamUnavailable
        }
        guard await Self.requestAccess() else {
            throw WearablesCameraError.permissionDenied
        }

        let session: PhoneCameraSession
        if let existingSession = self.session {
            session = existingSession
        } else {
            session = await PhoneCameraSession(previewHandler: previewHandler)
            self.session = session
        }

        guard await session.start() else {
            throw WearablesCameraError.streamUnavailable
        }
        isAvailable = true
    }

    func capturePhoto(timeout: Duration = .seconds(20)) async throws -> Data {
        guard isAvailable, let session else {
            throw WearablesCameraError.streamNotReady
        }
        return try await session.capturePhoto(timeout: timeout)
    }

    func stop() async {
        isAvailable = false
        await session?.stop()
    }
}
