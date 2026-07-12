//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit


struct HealthKitNutritionStore: NutritionHealthStoring {
    private let healthKit: SpeziHealthKit.HealthKit

    init(healthKit: SpeziHealthKit.HealthKit) {
        self.healthKit = healthKit
    }

    func save(_ analysis: NutritionAnalysis) async throws {
        try await healthKit.askForAuthorization()
        try await healthKit.healthStore.save(analysis.healthKitCorrelation())
    }
}
