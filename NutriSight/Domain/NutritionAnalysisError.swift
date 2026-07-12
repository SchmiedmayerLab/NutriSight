//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum NutritionAnalysisError: LocalizedError, Equatable, Sendable {
    case invalidImage
    case invalidResponse
    case missingTitle
    case missingFoods
    case invalidConfidence
    case invalidNutrientValue
    case duplicateNutrient

    var errorDescription: String? {
        switch self {
        case .invalidImage: String(localized: .errorInvalidImage)
        case .invalidResponse: String(localized: .errorInvalidResponse)
        case .missingTitle: String(localized: .errorMissingTitle)
        case .missingFoods: String(localized: .errorMissingFoods)
        case .invalidConfidence: String(localized: .errorInvalidConfidence)
        case .invalidNutrientValue: String(localized: .errorInvalidNutrientValue)
        case .duplicateNutrient: String(localized: .errorDuplicateNutrient)
        }
    }

    var recoverySuggestion: String? {
        String(localized: .errorRecoveryNutrition)
    }
}
