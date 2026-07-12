//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum NutritionAnalysisDecoder {
    static func decode(_ response: String) throws -> NutritionAnalysis {
        do {
            return try JSONDecoder().decode(NutritionAnalysis.self, from: Data(response.utf8)).validated()
        } catch let error as NutritionAnalysisError {
            throw error
        } catch {
            throw NutritionAnalysisError.invalidResponse
        }
    }
}
