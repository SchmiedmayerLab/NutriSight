//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
        }
        .onChange(of: didComplete) {
            guard didComplete else {
                return
            }
            configuration.completeOnboarding()
        }
    }
}
