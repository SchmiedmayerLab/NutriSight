//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum DeviceSessionManagerState: Equatable, Sendable {
    case noDevice
    case selectingDevice
    case connecting(deviceName: String?)
    case ready(deviceName: String?)
    case updateRequired(deviceName: String?)
    case incompatible(deviceName: String?)

    var deviceName: String? {
        switch self {
        case .noDevice, .selectingDevice:
            nil
        case .connecting(let deviceName),
             .ready(let deviceName),
             .updateRequired(let deviceName),
             .incompatible(let deviceName):
            deviceName
        }
    }
}
