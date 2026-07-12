//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension NutrientKind {
    var healthKitIdentifier: HKQuantityTypeIdentifier {
        switch self {
        case .energy: .dietaryEnergyConsumed
        case .protein: .dietaryProtein
        case .carbohydrates: .dietaryCarbohydrates
        case .totalFat: .dietaryFatTotal
        case .saturatedFat: .dietaryFatSaturated
        case .fiber: .dietaryFiber
        case .sugar: .dietarySugar
        case .sodium: .dietarySodium
        case .cholesterol: .dietaryCholesterol
        case .potassium: .dietaryPotassium
        case .calcium: .dietaryCalcium
        case .iron: .dietaryIron
        }
    }

    var healthKitUnit: HKUnit {
        switch self {
        case .energy:
            .kilocalorie()
        case .protein, .carbohydrates, .totalFat, .saturatedFat, .fiber, .sugar:
            .gram()
        case .sodium, .cholesterol, .potassium, .calcium, .iron:
            .gramUnit(with: .milli)
        }
    }
}
