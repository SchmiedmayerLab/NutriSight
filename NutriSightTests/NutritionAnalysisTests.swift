//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import NutriSight
import Testing


@MainActor
@Suite("Nutrition analysis")
struct NutritionAnalysisTests {
    @Test("Decodes valid model JSON")
    func decodesValidModelOutput() throws {
        let data = try JSONEncoder().encode(NutritionAnalysis.cheeseSpaetzleFixture)
        let json = try #require(String(data: data, encoding: .utf8))

        let result = try NutritionAnalysisDecoder.decode(json)

        #expect(result == .cheeseSpaetzleFixture)
    }

    @Test("Sample response represents every visible part of the test meal")
    func sampleResponseMatchesTestMeal() {
        let itemNames = NutritionAnalysis.cheeseSpaetzleFixture.items.map(\.name)

        #expect(itemNames.contains { $0.localizedCaseInsensitiveContains("spaetzle") })
        #expect(itemNames.contains { $0.localizedCaseInsensitiveContains("salad") })
        #expect(itemNames.contains { $0.localizedCaseInsensitiveContains("soft drink") })
    }

    @Test("Rejects malformed model output", arguments: [
        "",
        "No structured nutrition was returned.",
        "{}",
        "{\"title\":"
    ])
    func rejectsMalformedOutput(response: String) {
        #expect(throws: NutritionAnalysisError.invalidResponse) {
            try NutritionAnalysisDecoder.decode(response)
        }
    }

    @Test("Accepts confidence boundary", arguments: [0.0, 1.0])
    func acceptsConfidenceBoundary(confidence: Double) throws {
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture.replacing(confidence: confidence)

        #expect(try analysis.validated() == analysis)
    }

    @Test("Rejects missing titles", arguments: ["", "   \n"])
    func rejectsMissingTitle(title: String) {
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture.replacing(title: title)

        #expect(throws: NutritionAnalysisError.missingTitle) {
            try analysis.validated()
        }
    }

    @Test("Rejects missing foods")
    func rejectsMissingFoods() {
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture.replacing(items: [])

        #expect(throws: NutritionAnalysisError.missingFoods) {
            try analysis.validated()
        }
    }

    @Test("Rejects invalid confidence", arguments: [-0.01, 1.01, .nan, .infinity])
    func rejectsInvalidConfidence(confidence: Double) {
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture.replacing(confidence: confidence)

        #expect(throws: NutritionAnalysisError.invalidConfidence) {
            try analysis.validated()
        }
    }

    @Test("Rejects invalid nutrient values", arguments: [-1.0, .nan, .infinity])
    func rejectsInvalidNutrientValue(amount: Double) {
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture.replacing(
            nutrients: [NutrientValue(kind: .protein, amount: amount)]
        )

        #expect(throws: NutritionAnalysisError.invalidNutrientValue) {
            try analysis.validated()
        }
    }

    @Test("Rejects duplicate nutrient kinds")
    func rejectsDuplicateNutrients() {
        let analysis = NutritionAnalysis.cheeseSpaetzleFixture.replacing(nutrients: [
            NutrientValue(kind: .protein, amount: 20),
            NutrientValue(kind: .protein, amount: 25)
        ])

        #expect(throws: NutritionAnalysisError.duplicateNutrient) {
            try analysis.validated()
        }
    }
}


extension NutritionAnalysis {
    @MainActor
    fileprivate func replacing(title: String) -> NutritionAnalysis {
        NutritionAnalysis(
            title: title,
            summary: summary,
            items: items,
            nutrients: nutrients,
            confidence: confidence,
            caveats: caveats
        )
    }

    @MainActor
    fileprivate func replacing(items: [FoodItem]) -> NutritionAnalysis {
        NutritionAnalysis(
            title: title,
            summary: summary,
            items: items,
            nutrients: nutrients,
            confidence: confidence,
            caveats: caveats
        )
    }

    @MainActor
    fileprivate func replacing(nutrients: [NutrientValue]) -> NutritionAnalysis {
        NutritionAnalysis(
            title: title,
            summary: summary,
            items: items,
            nutrients: nutrients,
            confidence: confidence,
            caveats: caveats
        )
    }

    @MainActor
    fileprivate func replacing(confidence: Double) -> NutritionAnalysis {
        NutritionAnalysis(
            title: title,
            summary: summary,
            items: items,
            nutrients: nutrients,
            confidence: confidence,
            caveats: caveats
        )
    }
}
