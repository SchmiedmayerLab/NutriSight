//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLM
import SwiftUI


struct CaptureScreen: View {
    @Environment(LLMRunner.self) private var runner
    @Bindable var model: CaptureFeatureModel
    @Bindable var configuration: ExperienceConfiguration
    let setupGlassesAction: () -> Void

    @State private var presentsNutritionSheet = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .ignoresSafeArea()
            CameraPreviewCard(
                wearables: model.wearables,
                capturedImage: model.capturedImage,
                viewState: $model.viewState,
                captureAction: captureAndAnalyze
            )
            .ignoresSafeArea()
            CameraStatusOverlay(cameraState: model.wearables.state, configuration: configuration)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            CameraActionsView(
                model: model,
                captureAction: captureAndAnalyze,
                setupGlassesAction: setupGlassesAction
            )
            .padding()
        }
        .navigationTitle(.appTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $presentsNutritionSheet, onDismiss: model.retake) {
            NutritionAnalysisSheet(
                model: model,
                configuration: configuration,
                retryAction: retryAnalysis,
                closeAction: closeNutritionSheet
            )
        }
        .task(id: model.wearables.state) {
            await model.connectWhenReady()
        }
    }

    private func captureAndAnalyze() async throws {
        model.beginCapture()
        presentsNutritionSheet = true
        let operation = Task { @MainActor in
            try await model.capture()
            try? await analyzeCapturedPhoto()
        }
        do {
            try await operation.value
        } catch {
            model.cancelCapture()
            presentsNutritionSheet = false
            throw error
        }
    }

    private func analyzeCapturedPhoto() async throws {
        guard let analysisSource = configuration.analysisSource else {
            throw NutritionAnalysisError.invalidResponse
        }
        let analyzer = NutritionAnalyzerFactory.make(source: analysisSource, runner: runner)
        try await model.analyze(using: analyzer)
    }

    private func retryAnalysis() async throws {
        // Keep analysis alive when changing from the retry view to progress removes the originating button.
        let operation = Task { @MainActor in
            try await analyzeCapturedPhoto()
        }
        try? await operation.value
    }

    private func closeNutritionSheet() {
        presentsNutritionSheet = false
    }
}
