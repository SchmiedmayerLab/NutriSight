//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct GlassesSetupActionsView: View {
    @Bindable var configuration: ExperienceConfiguration
    let wearables: WearablesCoordinator
    @Binding var viewState: ViewState
    let isPairing: Bool
    let pairAction: @MainActor () async throws -> Void
    let simulatedGlassesAction: @MainActor () async throws -> Void
    let phoneCameraAction: @MainActor () async throws -> Void

    var body: some View {
        VStack(spacing: 10) {
            AsyncButton(state: $viewState, action: pairAction) {
                Label(pairingButtonTitle, systemImage: pairingButtonSystemImage)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .disabled(configuration.glassesSource == .metaGlasses && wearables.isRegistered)
            .accessibilityIdentifier("pair-meta-glasses")

            if LaunchConfiguration.allowsSimulatedGlasses {
                SimulatedGlassesSetupActionView(
                    isSelected: configuration.usesSimulatedGlasses,
                    viewState: $viewState,
                    action: simulatedGlassesAction
                )
            } else {
                PhoneCameraSetupActionView(
                    isSelected: configuration.usesPhoneCamera,
                    viewState: $viewState,
                    action: phoneCameraAction
                )
            }
        }
        .frame(maxWidth: .infinity)
        .viewStateAlert(state: $viewState)
    }

    private var pairingButtonTitle: LocalizedStringResource {
        if configuration.glassesSource == .metaGlasses && wearables.isRegistered {
            return .glassesPaired
        } else if isPairing {
            return .finishPairingInMetaAi
        }
        return .pairMetaGlasses
    }

    private var pairingButtonSystemImage: String {
        configuration.glassesSource == .metaGlasses && wearables.isRegistered ? "checkmark" : "eyeglasses"
    }
}


#Preview("Glasses Actions · Idle", traits: .fixedLayout(width: 402, height: 260)) {
    @Previewable @State var viewState: ViewState = .idle

    GlassesSetupActionsView(
        configuration: .preview(analysisSource: .sampleAnalysis),
        wearables: WearablesCoordinator(),
        viewState: $viewState,
        isPairing: false,
        pairAction: {},
        simulatedGlassesAction: {},
        phoneCameraAction: {}
    )
    .padding()
}


#Preview("Glasses Actions · Waiting for Meta AI", traits: .fixedLayout(width: 402, height: 260)) {
    @Previewable @State var viewState: ViewState = .idle

    GlassesSetupActionsView(
        configuration: .preview(analysisSource: .sampleAnalysis),
        wearables: WearablesCoordinator(previewImage: nil, state: .connecting),
        viewState: $viewState,
        isPairing: true,
        pairAction: {},
        simulatedGlassesAction: {},
        phoneCameraAction: {}
    )
    .padding()
}
