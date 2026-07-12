//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


@MainActor
protocol NutritionAnalyzing {
    func analyze(imageData: Data) async throws -> NutritionAnalysis
}
