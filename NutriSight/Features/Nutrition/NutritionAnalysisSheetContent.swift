//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionAnalysisSheetContent: View {
    @Bindable var model: CaptureFeatureModel
    @Bindable var configuration: ExperienceConfiguration
    let retryAction: @MainActor () async throws -> Void
    let closeAction: () -> Void

    var body: some View {
        Group {
            switch model.workflowState {
            case .capturing:
                NutritionAnalysisProgressView(configuration: configuration, workflowState: .capturing)
            case .analyzing:
                NutritionAnalysisProgressView(configuration: configuration, workflowState: .analyzing)
            case .captured:
                NutritionAnalysisRetryView(
                    viewState: $model.viewState,
                    retryAction: retryAction,
                    retakeAction: closeAction
                )
            case .result, .saved:
                if let analysis = model.analysis {
                    NutritionResultView(
                        model: model,
                        configuration: configuration,
                        analysis: analysis,
                        capturedImage: model.capturedImage,
                        closeAction: closeAction
                    )
                }
            case .camera:
                EmptyView()
            }
        }
    }
}
