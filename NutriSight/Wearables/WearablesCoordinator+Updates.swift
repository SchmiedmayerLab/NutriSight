//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MWDATCore


extension WearablesCoordinator {
    func openFirmwareUpdate() async throws {
        try await ensureMetaSourceSelected()
        try await wearables.openFirmwareUpdate()
    }

    func openGlassesAppUpdate() async throws {
        try await ensureMetaSourceSelected()
        try await wearables.openDATGlassesAppUpdate()
    }

    func openRequiredUpdate() async throws {
        switch requiredUpdate {
        case .glassesFirmware:
            try await openFirmwareUpdate()
        case .glassesApp:
            try await openGlassesAppUpdate()
        case .application:
            throw WearablesCameraError.incompatibleDevice
        case nil:
            return
        }
    }
}
