//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionAnalysisSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: CaptureFeatureModel
    @Bindable var configuration: ExperienceConfiguration
    let retryAction: @MainActor () async throws -> Void
    let closeAction: () -> Void

    @State private var selectedDetent: PresentationDetent = .medium

    var body: some View {
        Group {
            switch model.workflowState {
            case .capturing:
                NutritionAnalysisProgressView(
                    configuration: configuration,
                    title: .capturingMeal,
                    subtitle: .preparingPhotoForAnalysis
                )
            case .analyzing:
                NutritionAnalysisProgressView(
                    configuration: configuration,
                    title: .analyzingYourMeal,
                    subtitle: .analysisInProgress
                )
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
        .presentationDetents([.medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
        .interactiveDismissDisabled(model.workflowState == .capturing || model.workflowState == .analyzing)
        .onChange(of: model.workflowState) {
            guard model.workflowState == .result || model.workflowState == .saved else {
                return
            }
            if reduceMotion {
                selectedDetent = .large
            } else {
                withAnimation(.smooth) {
                    selectedDetent = .large
                }
            }
        }
    }
}
