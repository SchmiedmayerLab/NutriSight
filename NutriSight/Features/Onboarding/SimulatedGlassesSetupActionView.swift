//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SimulatedGlassesSetupActionView: View {
    let isSelected: Bool
    @Binding var viewState: ViewState
    let action: @MainActor () async throws -> Void

    var body: some View {
        VStack(spacing: 10) {
            AsyncButton(state: $viewState, action: action) {
                Label(.useSimulatedGlasses, systemImage: isSelected ? "checkmark" : "play.fill")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .disabled(isSelected)
            .accessibilityIdentifier("use-simulated-glasses")

            Text(.simulatedGlassesExplanation)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
