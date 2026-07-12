//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum WearablesCameraState: CaseIterable, Equatable, Sendable {
    case notRegistered
    case noDevice
    case permissionRequired
    case ready
    case connecting
    case streaming
    case paused

    var title: LocalizedStringResource {
        switch self {
        case .notRegistered: .connectMetaAi
        case .noDevice: .noGlassesFound
        case .permissionRequired: .cameraPermissionTitle
        case .ready: .connectingToGlasses
        case .connecting: .cameraConnecting
        case .streaming: .cameraReady
        case .paused: .cameraPaused
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .notRegistered: .cameraNotRegisteredDetail
        case .noDevice: .cameraNoDeviceDetail
        case .permissionRequired: .cameraPermissionDetail
        case .ready: .cameraConnectingDetail
        case .connecting: .cameraConnectingDetail
        case .streaming: .cameraReadyDetail
        case .paused: .cameraPausedDetail
        }
    }

    var systemImage: String {
        switch self {
        case .notRegistered: "link.badge.plus"
        case .noDevice: "eyeglasses"
        case .permissionRequired: "camera.badge.ellipsis"
        case .ready: "eyeglasses"
        case .connecting: "antenna.radiowaves.left.and.right"
        case .streaming: "camera.fill"
        case .paused: "pause.circle.fill"
        }
    }
}
