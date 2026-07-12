//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
@testable import NutriSight
import Testing


@MainActor
@Suite("HealthKit nutrition mapping")
struct HealthKitMappingTests {
    @Test("Every supported nutrient maps to the expected HealthKit type and unit")
    func mapsEveryNutrientExactly() {
        let expected: [NutrientKind: (HKQuantityTypeIdentifier, String)] = [
            .energy: (.dietaryEnergyConsumed, "kcal"),
            .protein: (.dietaryProtein, "g"),
            .carbohydrates: (.dietaryCarbohydrates, "g"),
            .totalFat: (.dietaryFatTotal, "g"),
            .saturatedFat: (.dietaryFatSaturated, "g"),
            .fiber: (.dietaryFiber, "g"),
            .sugar: (.dietarySugar, "g"),
            .sodium: (.dietarySodium, "mg"),
            .cholesterol: (.dietaryCholesterol, "mg"),
            .potassium: (.dietaryPotassium, "mg"),
            .calcium: (.dietaryCalcium, "mg"),
            .iron: (.dietaryIron, "mg")
        ]

        #expect(expected.count == NutrientKind.allCases.count)
        for kind in NutrientKind.allCases {
            let mapping = expected[kind]
            #expect(kind.healthKitIdentifier == mapping?.0)
            #expect(kind.healthKitUnit.unitString == mapping?.1)
        }
    }

    @Test("Builds a food correlation with exact values and metadata")
    func buildsFoodCorrelation() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture

        let correlation = analysis.healthKitCorrelation(at: date)

        #expect(correlation.correlationType.identifier == HKCorrelationTypeIdentifier.food.rawValue)
        #expect(correlation.startDate == date)
        #expect(correlation.endDate == date)
        #expect(correlation.metadata?[HKMetadataKeyFoodType] as? String == analysis.title)
        #expect(correlation.objects.count == analysis.nutrients.count)

        for nutrient in analysis.nutrients {
            let sample = try #require(correlation.objects.first { sample in
                sample.sampleType.identifier == nutrient.kind.healthKitIdentifier.rawValue
            } as? HKQuantitySample)
            #expect(sample.quantity.doubleValue(for: nutrient.kind.healthKitUnit) == nutrient.amount)
        }
    }

    @Test("Requests all twelve supported dietary write types")
    func requestsEveryWriteType() {
        #expect(NutritionHealthKitTypes.writable.count == NutrientKind.allCases.count)
    }
}
