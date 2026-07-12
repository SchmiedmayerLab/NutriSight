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
            HStack {
                Button(.retake, systemImage: "camera", action: retakeAction)
                    .buttonStyle(.glass)
                    .accessibilityIdentifier("retake-photo")
                AsyncButton(.tryAnalysisAgain, state: $viewState, action: retryAction)
                    .buttonStyle(.glassProminent)
                    .accessibilityIdentifier("retry-analysis")
            }
            .controlSize(.large)
        }
        .padding()
    }
}


#if DEBUG
#Preview("Analysis Retry") {
    @Previewable @State var viewState: ViewState = .idle

    NutritionAnalysisRetryView(
        viewState: $viewState,
        retryAction: {},
        retakeAction: {}
    )
}
#endif
