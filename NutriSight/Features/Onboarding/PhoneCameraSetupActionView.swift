//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct PhoneCameraSetupActionView: View {
    let isSelected: Bool
    @Binding var viewState: ViewState
    let action: @MainActor () async throws -> Void

    var body: some View {
        VStack(spacing: 10) {
            AsyncButton(state: $viewState, action: action) {
                Label("Use iPhone Camera", systemImage: isSelected ? "checkmark" : "camera")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .disabled(isSelected)
            .accessibilityIdentifier("use-phone-camera")

            Text("Allow camera access to capture meals with this iPhone when Meta glasses are not connected.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
