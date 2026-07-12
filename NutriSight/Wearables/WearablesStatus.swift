//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// An immutable snapshot of the public wearable lifecycle.
struct WearablesStatus: Equatable, Sendable {
    let source: GlassesSource?
    let state: WearablesCameraState
    let deviceName: String?
    let isRegistered: Bool
    let requiredUpdate: WearablesRequiredUpdate?
    let canCapture: Bool
}
