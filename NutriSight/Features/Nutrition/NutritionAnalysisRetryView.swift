//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NutritionAnalysisRetryView: View {
    @Binding var viewState: ViewState
    let retryAction: @MainActor () async throws -> Void
    let retakeAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ContentUnavailableView(
                .analysisNeedsAnotherTry,
                systemImage: "arrow.trianglehead.2.clockwise.rotate.90",
                description: Text(.analysisNeedsAnotherTryDescription)
            )
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    actionButtons
                }
                VStack(spacing: 10) {
                    actionButtons
                }
            }
            .controlSize(.large)
        }
        .padding()
    }

    @ViewBuilder private var actionButtons: some View {
        Button(action: retakeAction) {
            Label(.retake, systemImage: "camera")
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .accessibilityIdentifier("retake-photo")

        AsyncButton(state: $viewState, action: retryAction) {
            Text(.tryAnalysisAgain)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .accessibilityIdentifier("retry-analysis")
    }
}


#Preview("Analysis Retry") {
    @Previewable @State var viewState: ViewState = .idle

    NutritionAnalysisRetryView(
        viewState: $viewState,
        retryAction: {},
        retakeAction: {}
    )
}
