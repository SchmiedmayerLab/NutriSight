//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziLLM
import SpeziLLMOpenAI
import SpeziViews
import SwiftUI


struct CaptureExperienceView: View {
    @Bindable var configuration: ExperienceConfiguration
    @Bindable var wearables: WearablesCoordinator
    @State private var model: CaptureFeatureModel
    @State private var showsAPIKeySetup = false
    @State private var showsGlassesSetup = false
    @State private var didCompleteGlassesSetup = false
    @State private var glassesSetupPath = ManagedNavigationStack.Path()
    @State private var setupStartsAtCameraPermission = false
    @State private var pendingWearablesURL: URL?
    private let automaticallyStartsCamera: Bool

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
                        if configuration.usesPhoneCamera || !LaunchConfiguration.allowsSimulatedGlasses {
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
                if !setupStartsAtCameraPermission {
                    GlassesSetupOnboardingView(configuration: configuration)
                }
                GlassesCameraPermissionOnboardingView(configuration: configuration)
            }
        }
        .viewStateAlert(state: $model.viewState)
        .task {
            guard automaticallyStartsCamera else {
                return
            }
            await model.start(source: configuration.glassesSource)
        }
        .task(id: didCompleteGlassesSetup) {
            guard didCompleteGlassesSetup else {
                return
            }
            showsGlassesSetup = false
            await model.start(source: configuration.glassesSource)
        }
        .onOpenURL { url in
            guard !showsGlassesSetup, url.isMetaWearablesCallback else {
                return
            }
            pendingWearablesURL = url
        }
        .task(id: pendingWearablesURL) {
            if let pendingWearablesURL {
                await model.handleWearablesURL(pendingWearablesURL)
            }
        }
    }

    init(
        configuration: ExperienceConfiguration,
        wearables: WearablesCoordinator,
        automaticallyStartsCamera: Bool = true
    ) {
        self.configuration = configuration
        self.wearables = wearables
        self.automaticallyStartsCamera = automaticallyStartsCamera
        self._model = State(initialValue: CaptureFeatureModel(wearables: wearables))
    }

    private func presentGlassesSetup() {
        didCompleteGlassesSetup = false
        glassesSetupPath = ManagedNavigationStack.Path()
        setupStartsAtCameraPermission = model.wearables.state == .permissionRequired
        showsGlassesSetup = true
    }
}


#Preview("Capture Experience · Simulated") {
    let configuration = ExperienceConfiguration.preview(
        glassesSource: .simulatedGlasses,
        analysisSource: .sampleAnalysis
    )
    let wearables = WearablesCoordinator(previewImage: PreviewAssets.cheeseSpaetzle)

    CaptureExperienceView(
        configuration: configuration,
        wearables: wearables,
        automaticallyStartsCamera: false
    )
    .previewWith(standard: NutriSightStandard()) {
        LLMRunner {
            MetaMusePlatform(configuration: .init(authToken: .keychain(for: MetaMusePlatform.self)))
        }
    }
}


#Preview("Capture Experience · iPhone Camera") {
    let configuration = ExperienceConfiguration.preview(
        glassesSource: .phoneCamera,
        analysisSource: .sampleAnalysis
    )
    let wearables = WearablesCoordinator(previewImage: PreviewAssets.cheeseSpaetzle)

    CaptureExperienceView(
        configuration: configuration,
        wearables: wearables,
        automaticallyStartsCamera: false
    )
    .previewWith(standard: NutriSightStandard()) {
        LLMRunner {
            MetaMusePlatform(configuration: .init(authToken: .keychain(for: MetaMusePlatform.self)))
        }
    }
}


#Preview("Capture Experience · Camera Unavailable") {
    let configuration = ExperienceConfiguration.preview(
        glassesSource: .metaGlasses,
        analysisSource: .metaModel
    )
    let wearables = WearablesCoordinator(previewImage: nil, state: .noDevice)

    CaptureExperienceView(
        configuration: configuration,
        wearables: wearables,
        automaticallyStartsCamera: false
    )
    .previewWith(standard: NutriSightStandard()) {
        LLMRunner {
            MetaMusePlatform(configuration: .init(authToken: .keychain(for: MetaMusePlatform.self)))
        }
    }
}
