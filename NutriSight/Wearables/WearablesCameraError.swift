//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum WearablesCameraError: LocalizedError, Sendable {
    case noDevice
    case permissionDenied
    case sessionUnavailable
    case streamUnavailable
    case streamNotReady
    case captureRejected
    case captureTimedOut
    case sdk(String)

    var errorDescription: String? {
        switch self {
        case .noDevice: String(localized: .errorNoDevice)
        case .permissionDenied: String(localized: .errorPermissionDenied)
        case .sessionUnavailable: String(localized: .errorSessionUnavailable)
        case .streamUnavailable: String(localized: .errorStreamUnavailable)
        case .streamNotReady: String(localized: .errorStreamNotReady)
        case .captureRejected: String(localized: .errorCaptureRejected)
        case .captureTimedOut: String(localized: .errorCaptureTimedOut)
        case .sdk(let description): description
        }
    }

    var recoverySuggestion: String? {
        String(localized: .errorRecoveryWearables)
    }
}
