//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziLLM
import SpeziLLMOpenAI
import SwiftUI


struct SpeziNutritionAnalyzer: NutritionAnalyzing {
    private static let systemPrompt = """
        You are a careful nutrition estimation assistant. Analyze only visible food. Quantities are estimates, not medical advice.
        Return one JSON object and no Markdown. Use the exact keys and enum values requested by the user.
        Do not invent a nutrient that cannot reasonably be estimated; omit it from the nutrients array instead.
        """

    private static let userPrompt = """
        Identify this meal and estimate its nutritional content. Return exactly this JSON shape:
        {
          "title": "short meal name",
          "summary": "one concise sentence",
          "items": [{"name": "food", "estimatedPortion": "human-readable portion"}],
          "nutrients": [{
            "kind": "energy|protein|carbohydrates|totalFat|saturatedFat|fiber|sugar|sodium|cholesterol|potassium|calcium|iron",
            "amount": 0
          }],
          "confidence": 0.0,
          "caveats": ["important uncertainty"]
        }
        Units are fixed: energy is kcal; protein, carbohydrates, totalFat, saturatedFat, fiber, and sugar are grams;
        sodium, cholesterol, potassium, calcium, and iron are milligrams. Include each nutrient at most once.
        """

    private let runner: LLMRunner

    init(runner: LLMRunner) {
        self.runner = runner
    }

    func analyze(imageData: Data) async throws -> NutritionAnalysis {
        guard let image = UIImage(data: imageData),
              let imageEntity = LLMContextEntity(
                _role: .user,
                image: image,
                format: .jpeg(compressionFactor: 0.82)
              ) else {
            throw NutritionAnalysisError.invalidImage
        }

        let schema = MetaMuseSchema(
            parameters: .init(
                modelType: .museSpark11,
                systemPrompt: Self.systemPrompt
            ),
            modelParameters: .init(
                responseFormat: .jsonObject,
                temperature: 0.1,
                maxOutputLength: 2_000
            )
        )
        let context: LLMContext = [
            .init(role: .user, content: Self.userPrompt),
            imageEntity
        ]
        let response: String = try await runner.oneShot(with: schema, context: context)
        return try NutritionAnalysisDecoder.decode(response)
    }
}
