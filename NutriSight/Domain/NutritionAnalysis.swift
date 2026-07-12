//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct NutritionAnalysis: Codable, Equatable, Sendable {
    let title: String
    let summary: String
    let items: [FoodItem]
    let nutrients: [NutrientValue]
    let confidence: Double
    let caveats: [String]

    func validated() throws -> Self {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NutritionAnalysisError.missingTitle
        }
        guard !items.isEmpty else {
            throw NutritionAnalysisError.missingFoods
        }
        guard (0...1).contains(confidence) else {
            throw NutritionAnalysisError.invalidConfidence
        }
        guard nutrients.allSatisfy({ $0.amount.isFinite && $0.amount >= 0 }) else {
            throw NutritionAnalysisError.invalidNutrientValue
        }
        guard Set(nutrients.map(\.kind)).count == nutrients.count else {
            throw NutritionAnalysisError.duplicateNutrient
        }
        return self
    }
}
