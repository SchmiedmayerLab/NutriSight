//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum NutrientKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case energy
    case protein
    case carbohydrates
    case totalFat
    case saturatedFat
    case fiber
    case sugar
    case sodium
    case cholesterol
    case potassium
    case calcium
    case iron

    var id: Self { self }

    var displayName: LocalizedStringResource {
        switch self {
        case .energy: .nutrientEnergy
        case .protein: .nutrientProtein
        case .carbohydrates: .nutrientCarbohydrates
        case .totalFat: .nutrientTotalFat
        case .saturatedFat: .nutrientSaturatedFat
        case .fiber: .nutrientFiber
        case .sugar: .nutrientSugar
        case .sodium: .nutrientSodium
        case .cholesterol: .nutrientCholesterol
        case .potassium: .nutrientPotassium
        case .calcium: .nutrientCalcium
        case .iron: .nutrientIron
        }
    }

    func formattedAmount(_ amount: Double, locale: Locale = .current) -> String {
        switch self {
        case .energy:
            Measurement(value: amount, unit: UnitEnergy.kilocalories)
                .formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(locale))
        case .protein, .carbohydrates, .totalFat, .saturatedFat, .fiber, .sugar:
            Measurement(value: amount, unit: UnitMass.grams)
                .formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(locale))
        case .sodium, .cholesterol, .potassium, .calcium, .iron:
            Measurement(value: amount, unit: UnitMass.milligrams)
                .formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(locale))
        }
    }
}
