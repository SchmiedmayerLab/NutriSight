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
    @State private var showsGlassesSetup = false
    @State private var didCompleteGlassesSetup = false
    @State private var glassesSetupPath = ManagedNavigationStack.Path()

    var body: some View {
        NavigationStack {
            CaptureScreen(
                model: model,
                configuration: configuration,
                setupGlassesAction: presentGlassesSetup
            )
            .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu(.setupAndSources, systemImage: "ellipsis") {
                            if configuration.usesSimulatedGlasses {
                                Label(.simulatedGlasses, systemImage: "eyeglasses")
                            }
                            if configuration.usesPhoneCamera {
                                Label("iPhone Camera", systemImage: "camera")
                            }
                            if !LaunchConfiguration.allowsSimulatedGlasses {
                                Button(.pairMetaGlasses, systemImage: "eyeglasses", action: presentGlassesSetup)
                                .accessibilityIdentifier("pair-meta-glasses-later")
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
        .sheet(isPresented: $showsGlassesSetup) {
            ManagedNavigationStack(didComplete: $didCompleteGlassesSetup, path: glassesSetupPath) {
                GlassesSetupOnboardingView(configuration: configuration)
            }
            .onChange(of: didCompleteGlassesSetup) {
                guard didCompleteGlassesSetup else {
                    return
                }
                showsGlassesSetup = false
                model.start(source: configuration.glassesSource)
            }
        }
        .viewStateAlert(state: $model.viewState)
        .task {
            model.start(source: configuration.glassesSource)
        }
        .onOpenURL { url in
            guard !showsGlassesSetup, url.isMetaWearablesCallback else {
                return
            }
            Task {
                await model.handleWearablesURL(url)
            }
        }
    }

    private func presentGlassesSetup() {
        didCompleteGlassesSetup = false
        glassesSetupPath = ManagedNavigationStack.Path()
        showsGlassesSetup = true
    }
}
