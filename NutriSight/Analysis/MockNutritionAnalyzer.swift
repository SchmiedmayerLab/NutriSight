//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct MockNutritionAnalyzer: NutritionAnalyzing {
    private let shouldFail: Bool
    private let delay: Duration

    init(shouldFail: Bool = false, delay: Duration = .zero) {
        self.shouldFail = shouldFail
        self.delay = delay
    }

    func analyze(imageData: Data) async throws -> NutritionAnalysis {
        guard !imageData.isEmpty else {
            throw NutritionAnalysisError.invalidImage
        }
        if delay > .zero {
            try await Task.sleep(for: delay)
        }
        guard !shouldFail else {
            throw NutritionAnalysisError.invalidResponse
        }
        return .cheeseSpaetzleFixture
    }
}
