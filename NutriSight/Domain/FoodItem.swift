//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct FoodItem: Codable, Equatable, Identifiable, Sendable {
    let name: String
    let estimatedPortion: String

    var id: String { "\(name)-\(estimatedPortion)" }
}
