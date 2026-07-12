//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLM


@MainActor
enum NutritionAnalyzerFactory {
    static func make(source: AnalysisSource, runner: LLMRunner) -> any NutritionAnalyzing {
        switch source {
        case .metaModel:
            SpeziNutritionAnalyzer(runner: runner)
        case .sampleAnalysis:
            MockNutritionAnalyzer(
                shouldFail: LaunchConfiguration.simulatesMockLLMFailure,
                delay: .seconds(3)
            )
        }
    }
}
