//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


enum CaptureWorkflowState: Equatable, Sendable {
    case camera
    case capturing
    case captured
    case analyzing
    case result
    case saved
}
