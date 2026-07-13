//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionAnalysisProgressView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let configuration: ExperienceConfiguration
    let workflowState: CaptureWorkflowState

    @State private var stage: NutritionAnalysisStage

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.title2.weight(.semibold))
                    .symbolEffect(.pulse, options: .repeating, value: stage)
                    .frame(width: 52, height: 52)
                    .background(.tint.opacity(0.14), in: .circle)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(stage.title)
                        .font(.title2.bold())
                        .contentTransition(.opacity)
                    Text(stage.detail)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ProgressView(value: stage.progress)
                .progressViewStyle(.linear)
                .animation(progressAnimation, value: stage)

            if configuration.usesSampleAnalysis {
                Label(.sampleAnalysisActive, systemImage: "wand.and.stars")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("analysis-progress")
        .task(id: workflowState) {
            await advanceProgress()
        }
    }

    private var progressAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.15) : .smooth(duration: 0.7)
    }

    init(configuration: ExperienceConfiguration, workflowState: CaptureWorkflowState) {
        self.configuration = configuration
        self.workflowState = workflowState
        self._stage = State(initialValue: workflowState == .capturing ? .capturingPhoto : .preparingImage)
    }

    private func advanceProgress() async {
        guard workflowState == .analyzing else {
            stage = .capturingPhoto
            return
        }
        stage = .preparingImage
        for nextStage in NutritionAnalysisStage.analysisStages.dropFirst() {
            do {
                try await Task.sleep(for: nextStage.delayBeforePresentation)
            } catch {
                return
            }
            withAnimation(progressAnimation) {
                stage = nextStage
            }
        }
    }
}


#Preview("Analysis Progress · Staged", traits: .fixedLayout(width: 402, height: 320)) {
    NutritionAnalysisProgressView(
        configuration: .preview(glassesSource: .simulatedGlasses, analysisSource: .sampleAnalysis),
        workflowState: .analyzing
    )
    .background(.ultraThinMaterial)
}


#Preview("Analysis Progress · Capturing", traits: .fixedLayout(width: 402, height: 260)) {
    NutritionAnalysisProgressView(
        configuration: .preview(glassesSource: .metaGlasses, analysisSource: .metaModel),
        workflowState: .capturing
    )
    .background(.ultraThinMaterial)
}
