//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziKeychainStorage
import SpeziViews
import SwiftUI


struct SetupFlowView: View {
    @Bindable var configuration: ExperienceConfiguration
    @State private var didComplete = false
    @State private var path = ManagedNavigationStack.Path()

    var body: some View {
        ManagedNavigationStack(didComplete: $didComplete, path: path) {
            WelcomeOnboardingView()
            AnalysisSetupOnboardingView(configuration: configuration)
            GlassesSetupOnboardingView(configuration: configuration)
            GlassesCameraPermissionOnboardingView(configuration: configuration)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onChange(of: didComplete) {
            guard didComplete else {
                return
            }
            configuration.completeOnboarding()
        }
    }
}


#Preview("Complete Setup Flow", traits: .fixedLayout(width: 402, height: 874)) {
    SetupFlowView(configuration: .preview())
        .environment(WearablesCoordinator())
        .previewWith {
            KeychainStorage()
        }
}
