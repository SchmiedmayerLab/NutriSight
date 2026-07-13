//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct GlassesSetupOnboardingView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Environment(WearablesCoordinator.self) private var wearables
    @Bindable var configuration: ExperienceConfiguration

    @State private var viewState: ViewState = .idle
    @State private var isPairing = false
    @State private var registrationCallbackURL: URL?

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
            GlassesSetupActionsView(
                configuration: configuration,
                wearables: wearables,
                viewState: $viewState,
                isPairing: isPairing,
                pairAction: pairMetaGlasses,
                simulatedGlassesAction: useSimulatedGlasses,
                phoneCameraAction: usePhoneCamera
            )
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onOpenURL(perform: receiveWearablesURL)
        .task(id: registrationCallbackURL) {
            await handleRegistrationCallback()
        }
        .onChange(of: wearables.state) {
            guard isPairing, wearables.isRegistered else {
                return
            }
            completeMetaGlassesPairing()
        }
    }

    private func pairMetaGlasses() async throws {
        isPairing = true
        do {
            try await wearables.selectSource(.metaGlasses)
            if wearables.isRegistered {
                completeMetaGlassesPairing()
                return
            }
            try await wearables.pair()
            if wearables.isRegistered {
                completeMetaGlassesPairing()
            }
        } catch {
            isPairing = false
            throw error
        }
    }

    private func completeMetaGlassesPairing() {
        guard isPairing else {
            return
        }
        configuration.selectGlassesSource(.metaGlasses)
        isPairing = false
        path.nextStep()
    }

    private func useSimulatedGlasses() async throws {
        guard LaunchConfiguration.allowsSimulatedGlasses else {
            return
        }
        configuration.selectGlassesSource(.simulatedGlasses)
        try await wearables.selectSource(.simulatedGlasses)
        path.nextStep()
        path.nextStep()
    }

    private func usePhoneCamera() async throws {
        guard PhoneCamera.isSupported else {
            throw WearablesCameraError.streamUnavailable
        }
        guard await PhoneCamera.requestAccess() else {
            throw WearablesCameraError.permissionDenied
        }
        configuration.selectGlassesSource(.phoneCamera)
        try await wearables.selectSource(.phoneCamera)
        path.nextStep()
        path.nextStep()
    }

    private func receiveWearablesURL(_ url: URL) {
        guard url.isMetaWearablesCallback else {
            return
        }
        isPairing = true
        viewState = .idle
        registrationCallbackURL = url
    }

    private func handleRegistrationCallback() async {
        guard let registrationCallbackURL else {
            return
        }
        do {
            try await wearables.handleRegistrationCallback(registrationCallbackURL)
            guard wearables.isRegistered else {
                isPairing = false
                return
            }
            completeMetaGlassesPairing()
        } catch let error as any LocalizedError {
            Logger.wearables.error("Unable to complete Meta Wearables registration: \(error.localizedDescription)")
            isPairing = false
            viewState = .error(error)
        } catch {
            Logger.wearables.error("Unable to complete Meta Wearables registration: \(error.localizedDescription)")
            isPairing = false
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }
}


#Preview("Glasses Setup", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        GlassesSetupOnboardingView(configuration: .preview(analysisSource: .sampleAnalysis))
            .environment(WearablesCoordinator())
    }
}
