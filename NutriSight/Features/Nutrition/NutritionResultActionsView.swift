//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NutritionResultActionsView: View {
    @Bindable var model: CaptureFeatureModel
    let configuration: ExperienceConfiguration
    let saveAction: @MainActor () async throws -> Void
    let analyzeAnotherAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            if model.workflowState == .saved {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                        .symbolEffect(.bounce, options: .repeat(2), value: model.workflowState)
                        .accessibilityHidden(true)
                    Text(configuration.usesMockHealthKit ? .simulatedSaveComplete : .savedToAppleHealth)
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.tint(.green.opacity(0.12)), in: .rect(cornerRadius: 18))
                .transition(.blurReplace)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("health-save-confirmation")
            } else {
                AsyncButton(state: $model.viewState, action: saveAction) {
                    Text(.save)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .transition(.blurReplace)
                .accessibilityIdentifier("save-health")
            }
            Button(action: analyzeAnotherAction) {
                Label(.analyzeAnotherMeal, systemImage: "camera")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .accessibilityIdentifier("analyze-another")
        }
        .animation(.smooth, value: model.workflowState)
    }
}
