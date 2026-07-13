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
            if showsDismissButton {
                NavigationStack {
                    NutritionAnalysisSheetContent(
                        model: model,
                        configuration: configuration,
                        retryAction: retryAction,
                        closeAction: closeAction
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(model.analysis?.title ?? "")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(.close, systemImage: "xmark", action: closeAction)
                                .accessibilityIdentifier("close-nutrition-results")
                        }
                    }
                }
            } else {
                NutritionAnalysisSheetContent(
                    model: model,
                    configuration: configuration,
                    retryAction: retryAction,
                    closeAction: closeAction
                )
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.smooth, value: model.workflowState)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationDetents(availableDetents)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
        .presentationBackground(.ultraThinMaterial)
        .interactiveDismissDisabled(model.workflowState == .capturing || model.workflowState == .analyzing)
    }

    private var showsDismissButton: Bool {
        model.workflowState == .result || model.workflowState == .saved
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

    ZStack {
        Image(uiImage: PreviewAssets.cheeseSpaetzle ?? UIImage())
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        Button("Present Analysis Sheet") {
            presentsSheet = true
        }
        .buttonStyle(.glassProminent)
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

    ZStack {
        Image(uiImage: PreviewAssets.cheeseSpaetzle ?? UIImage())
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        Button("Present Analysis Sheet") {
            presentsSheet = true
        }
        .buttonStyle(.glassProminent)
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
