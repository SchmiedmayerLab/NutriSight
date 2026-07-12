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
        VStack(spacing: 8) {
            if model.workflowState == .saved {
                Label(
                    configuration.preventsAppleHealthWrite
                        ? .simulatedSaveComplete
                        : .savedToAppleHealth,
                    systemImage: "checkmark.circle.fill"
                )
                .font(.headline)
                .padding()
                .glassEffect(.regular, in: .capsule)
                .accessibilityIdentifier("health-save-confirmation")
            } else {
                AsyncButton(
                    .save,
                    state: $model.viewState,
                    action: saveAction
                )
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .accessibilityIdentifier("save-health")
            }
            Button(.analyzeAnotherMeal, systemImage: "camera", action: analyzeAnotherAction)
                .buttonStyle(.glass)
                .controlSize(.large)
                .accessibilityIdentifier("analyze-another")
        }
    }
}
