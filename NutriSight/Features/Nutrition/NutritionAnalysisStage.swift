//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum NutritionAnalysisStage: CaseIterable, Equatable, Sendable {
    case capturingPhoto
    case preparingImage
    case identifyingFoods
    case estimatingPortions
    case calculatingNutrition
    case reviewingEstimate
    case finalizingResults

    static let analysisStages: [NutritionAnalysisStage] = [
        .preparingImage,
        .identifyingFoods,
        .estimatingPortions,
        .calculatingNutrition,
        .reviewingEstimate,
        .finalizingResults
    ]

    var progress: Double {
        switch self {
        case .capturingPhoto: 0.08
        case .preparingImage: 0.18
        case .identifyingFoods: 0.34
        case .estimatingPortions: 0.52
        case .calculatingNutrition: 0.69
        case .reviewingEstimate: 0.84
        case .finalizingResults: 0.94
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .capturingPhoto: .capturingMeal
        case .preparingImage: .preparingMealPhoto
        case .identifyingFoods: .identifyingFoods
        case .estimatingPortions: .estimatingPortions
        case .calculatingNutrition: .calculatingNutrition
        case .reviewingEstimate: .reviewingEstimate
        case .finalizingResults: .finalizingResults
        }
    }

    var detail: LocalizedStringResource {
        switch self {
        case .capturingPhoto: .preparingPhotoForAnalysis
        case .preparingImage: .preparingImageForModel
        case .identifyingFoods: .identifyingFoodsDetail
        case .estimatingPortions: .estimatingPortionsDetail
        case .calculatingNutrition: .calculatingNutritionDetail
        case .reviewingEstimate: .reviewingEstimateDetail
        case .finalizingResults: .finalizingResultsDetail
        }
    }

    var delayBeforePresentation: Duration {
        switch self {
        case .capturingPhoto, .preparingImage: .zero
        case .identifyingFoods: .seconds(1.2)
        case .estimatingPortions: .seconds(2)
        case .calculatingNutrition: .seconds(2.8)
        case .reviewingEstimate: .seconds(3.6)
        case .finalizingResults: .seconds(4.5)
        }
    }
}
