//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

/// Identifies which layer must be updated before a camera session can be created.
enum WearablesRequiredUpdate: Equatable, Sendable {
    case glassesFirmware
    case glassesApp
    case application
}
