//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct CaptureExperienceView: View {
    @Bindable var configuration: ExperienceConfiguration
    @State private var model = CaptureFeatureModel()
    @State private var showsAPIKeySetup = false

    var body: some View {
        NavigationStack {
            CaptureScreen(model: model, configuration: configuration)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu(.setupAndSources, systemImage: "ellipsis") {
                            if configuration.usesSimulatedGlasses {
                                Label(.simulatedGlasses, systemImage: "eyeglasses")
                            }
                            if configuration.usesSampleAnalysis {
                                Label(.sampleAnalysis, systemImage: "wand.and.stars")
                            }
                            Button(.metaApiKey, systemImage: "key") {
                                showsAPIKeySetup = true
                            }
                            .accessibilityIdentifier("meta-api-key")
                        }
                        .accessibilityIdentifier("experience-menu")
                    }
                }
        }
        .sheet(isPresented: $showsAPIKeySetup) {
            MetaAPIKeySetupView()
        }
        .viewStateAlert(state: $model.viewState)
        .task {
            model.start()
        }
        .onOpenURL { url in
            Task {
                await model.handleWearablesURL(url)
            }
        }
    }
}
