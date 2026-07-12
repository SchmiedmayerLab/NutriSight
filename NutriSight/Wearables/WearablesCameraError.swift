//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum WearablesCameraError: Equatable, LocalizedError, Sendable {
    case registrationRequired
    case noDevice
    case permissionRequired
    case permissionDenied
    case deviceUpdateRequired
    case incompatibleDevice
    case sessionUnavailable
    case streamUnavailable
    case streamNotReady
    case captureRejected
    case captureTimedOut
    case sdk(String)

    var errorDescription: String? {
        switch self {
        case .registrationRequired: String(localized: .errorRegistrationRequired)
        case .noDevice: String(localized: .errorNoDevice)
        case .permissionRequired: String(localized: .errorPermissionRequired)
        case .permissionDenied: String(localized: .errorPermissionDenied)
        case .deviceUpdateRequired: String(localized: .errorDeviceUpdateRequired)
        case .incompatibleDevice: String(localized: .errorIncompatibleDevice)
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
