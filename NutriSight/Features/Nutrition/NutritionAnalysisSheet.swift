//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit
import SwiftUI


struct NutritionAnalysisSheet: View {
    @ScaledMetric(relativeTo: .body) private var compactSheetHeight: CGFloat = 200
    @Bindable var model: CaptureFeatureModel
    @Bindable var configuration: ExperienceConfiguration
    let retryAction: @MainActor () async throws -> Void
    let closeAction: () -> Void

    var body: some View {
        Group {
            switch model.workflowState {
            case .capturing:
                NutritionAnalysisProgressView(
                    configuration: configuration,
                    workflowState: .capturing
                )
            case .analyzing:
                NutritionAnalysisProgressView(
                    configuration: configuration,
                    workflowState: .analyzing
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
        .id(model.workflowState)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.smooth, value: model.workflowState)
        .presentationDetents(availableDetents)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .presentationBackground(.ultraThinMaterial)
        .interactiveDismissDisabled(model.workflowState == .capturing || model.workflowState == .analyzing)
    }

    private var availableDetents: Set<PresentationDetent> {
        switch model.workflowState {
        case .capturing, .analyzing: [.height(compactSheetHeight)]
        case .captured: [.medium]
        case .result, .saved, .camera: [.large]
        }
    }
}


#Preview("Nutrition Sheet · Progress", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var presentsSheet = true
    @Previewable @State var model = CaptureFeatureModel(previewWorkflowState: .analyzing)
    @Previewable @State var configuration = ExperienceConfiguration.preview(
        glassesSource: .simulatedGlasses,
        analysisSource: .sampleAnalysis
    )

    Button("Present Analysis Sheet") {
        presentsSheet = true
    }
    .sheet(isPresented: $presentsSheet) {
        NutritionAnalysisSheet(
            model: model,
            configuration: configuration,
            retryAction: {},
            closeAction: {}
        )
    }
}


#Preview("Nutrition Sheet · Accessibility Text", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var presentsSheet = true
    @Previewable @State var model = CaptureFeatureModel(previewWorkflowState: .analyzing)
    @Previewable @State var configuration = ExperienceConfiguration.preview(
        glassesSource: .simulatedGlasses,
        analysisSource: .sampleAnalysis
    )

    Button("Present Analysis Sheet") {
        presentsSheet = true
    }
    .sheet(isPresented: $presentsSheet) {
        NutritionAnalysisSheet(
            model: model,
            configuration: configuration,
            retryAction: {},
            closeAction: {}
        )
        .dynamicTypeSize(.accessibility2)
    }
}


#Preview("Nutrition Sheet · Result", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var presentsSheet = true
    @Previewable @State var model = CaptureFeatureModel(
        previewWorkflowState: .result,
        analysis: .cheeseSpaetzleFixture
    )
    @Previewable @State var configuration = ExperienceConfiguration.preview(
        glassesSource: .simulatedGlasses,
        analysisSource: .sampleAnalysis
    )

    Button("Present Result Sheet") {
        presentsSheet = true
    }
    .sheet(isPresented: $presentsSheet) {
        NutritionAnalysisSheet(
            model: model,
            configuration: configuration,
            retryAction: {},
            closeAction: {}
        )
    }
    .previewWith(standard: NutriSightStandard()) {
        SpeziHealthKit.HealthKit {
            RequestWriteAccess(quantity: NutritionHealthKitTypes.writable)
        }
    }
}
