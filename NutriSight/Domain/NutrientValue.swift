//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct NutrientValue: Codable, Equatable, Identifiable, Sendable {
    let kind: NutrientKind
    let amount: Double

    var id: NutrientKind { kind }
}
