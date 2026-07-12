//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MWDATCore
import OSLog
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct GlassesSetupOnboardingView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Bindable var configuration: ExperienceConfiguration

    var body: some View {
        OnboardingView {
            OnboardingHeroView(
                systemImage: "eyeglasses",
                title: .glassesSetupTitle,
                subtitle: .glassesSetupSubtitle
            )
        } content: {
            OnboardingInformationView(areas: [
                OnboardingInformationView.Area(
                    iconSymbol: "video.fill",
                    title: .livePointOfView,
                    description: .livePointOfViewDescription
                ),
                OnboardingInformationView.Area(
                    iconSymbol: "hand.tap",
                    title: .captureInTheApp,
                    description: .captureInTheAppDescription
                )
            ])
        } footer: {
            VStack(spacing: 8) {
                OnboardingActionsView(
                    primaryTitle: .pairMetaGlasses,
                    primaryAction: pairMetaGlasses,
                    secondaryTitle: .useSimulatedGlasses,
                    secondaryAction: useSimulatedGlasses
                )
                .accessibilityIdentifier("glasses-setup-actions")
                Text(.simulatedGlassesExplanation)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle(.glasses)
        .navigationBarTitleDisplayMode(.inline)
        .onOpenURL(perform: handleWearablesURL)
    }

    private func pairMetaGlasses() async throws {
        configuration.selectGlassesSource(.metaGlasses)
        try WearablesBootstrap.configure(using: .metaGlasses)
        if Wearables.shared.registrationState == .registered {
            path.nextStep()
        } else {
            try await Wearables.shared.startRegistration()
        }
    }

    private func useSimulatedGlasses() throws {
        configuration.selectGlassesSource(.simulatedGlasses)
        try WearablesBootstrap.configure(using: .simulatedGlasses)
        path.nextStep()
    }

    private func handleWearablesURL(_ url: URL) {
        Task {
            do {
                _ = try await Wearables.shared.handleUrl(url)
                guard Wearables.shared.registrationState == .registered else {
                    return
                }
                path.nextStep()
            } catch {
                Logger.wearables.error("Unable to complete Meta Wearables registration: \(error.localizedDescription)")
            }
        }
    }
}


#if DEBUG
#Preview("Glasses Setup") {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        GlassesSetupOnboardingView(configuration: .preview(analysisSource: .sampleAnalysis))
    }
}
#endif
