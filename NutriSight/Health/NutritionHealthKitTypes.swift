//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit


enum NutritionHealthKitTypes {
    static let writable: Set<SampleType<HKQuantitySample>> = [
        .dietaryEnergyConsumed,
        .dietaryProtein,
        .dietaryCarbohydrates,
        .dietaryFatTotal,
        .dietaryFatSaturated,
        .dietaryFiber,
        .dietarySugar,
        .dietarySodium,
        .dietaryCholesterol,
        .dietaryPotassium,
        .dietaryCalcium,
        .dietaryIron
    ]
}
