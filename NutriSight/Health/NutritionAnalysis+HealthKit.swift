//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit


extension NutritionAnalysis {
    func healthKitCorrelation(at date: Date = .now) -> HKCorrelation {
        let samples = nutrients.map { nutrient in
            let type = HKQuantityType(nutrient.kind.healthKitIdentifier)
            let quantity = HKQuantity(unit: nutrient.kind.healthKitUnit, doubleValue: nutrient.amount)
            return HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        }
        return HKCorrelation(
            type: HKCorrelationType(.food),
            start: date,
            end: date,
            objects: Set(samples),
            metadata: [HKMetadataKeyFoodType: title]
        )
    }
}
