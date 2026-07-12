//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct WelcomeOnboardingView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path

    var body: some View {
        OnboardingView {
            OnboardingHeroView(
                systemImage: "camera.viewfinder",
                title: .welcomeTitle,
                subtitle: .welcomeSubtitle
            )
        } content: {
            OnboardingInformationView(areas: [
                OnboardingInformationView.Area(
                    iconSymbol: "eyeglasses",
                    title: .welcomeCaptureTitle,
                    description: .welcomeCaptureDescription
                ),
                OnboardingInformationView.Area(
                    iconSymbol: "wand.and.stars",
                    title: .welcomeEstimateTitle,
                    description: .welcomeEstimateDescription
                ),
                OnboardingInformationView.Area(
                    iconSymbol: "heart.text.clipboard",
                    title: .welcomeReviewTitle,
                    description: .welcomeReviewDescription
                )
            ])
        } footer: {
            Button {
                path.nextStep()
            } label: {
                Text(.getStarted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .accessibilityIdentifier("welcome-continue")
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview("Welcome") {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        WelcomeOnboardingView()
    }
}
