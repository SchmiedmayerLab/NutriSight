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


struct GlassesCameraPermissionOnboardingView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Environment(WearablesCoordinator.self) private var wearables
    @Bindable var configuration: ExperienceConfiguration

    @State private var permissionGranted = false
    @State private var viewState: ViewState = .idle
    @State private var registrationCallbackURL: URL?

    private var canContinue: Bool {
        permissionGranted || wearables.state == .ready
    }

    var body: some View {
        OnboardingView {
            OnboardingHeroView(
                systemImage: "camera.badge.ellipsis",
                title: .cameraPermissionTitle,
                subtitle: .cameraPermissionSubtitle
            )
        } content: {
            OnboardingInformationView(areas: [
                OnboardingInformationView.Area(
                    iconSymbol: "checkmark.circle",
                    title: .glassesPaired,
                    description: .glassesPairedDetail
                ),
                OnboardingInformationView.Area(
                    iconSymbol: "camera.fill",
                    title: .cameraAccess,
                    description: .cameraAccessDetail
                ),
                OnboardingInformationView.Area(
                    iconSymbol: "video.fill",
                    title: .cameraStartsNext,
                    description: .cameraStartsNextDetail
                )
            ])
        } footer: {
            VStack(spacing: 10) {
                AsyncButton(state: $viewState, action: grantPermissionAndContinue) {
                    Text(permissionGranted ? .continueToCamera : .allowGlassesCamera)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(!canContinue)
                .accessibilityIdentifier("allow-glasses-camera")

                if !permissionGranted && wearables.state != .ready {
                    Label(.waitingForActiveGlasses, systemImage: "hourglass")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .viewStateAlert(state: $viewState)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .task {
            await preparePermissionStep()
        }
        .task(id: wearables.state) {
            await refreshPermissionStatus()
        }
        .onOpenURL(perform: receiveWearablesURL)
        .task(id: registrationCallbackURL) {
            await handleRegistrationCallback()
        }
    }

    private func preparePermissionStep() async {
        guard configuration.glassesSource == .metaGlasses else {
            path.nextStep()
            return
        }
        do {
            try await wearables.selectSource(.metaGlasses)
            await refreshPermissionStatus()
        } catch let error as any LocalizedError {
            viewState = .error(error)
        } catch {
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }

    private func refreshPermissionStatus() async {
        guard wearables.isRegistered, wearables.state == .ready else {
            return
        }
        do {
            permissionGranted = try await wearables.cameraAccessIsGranted()
        } catch {
            permissionGranted = false
        }
    }

    private func grantPermissionAndContinue() async throws {
        if !permissionGranted {
            try await wearables.requestCameraAccess()
            permissionGranted = true
        }
        path.nextStep()
    }

    private func receiveWearablesURL(_ url: URL) {
        guard url.isMetaWearablesCallback else {
            return
        }
        registrationCallbackURL = url
    }

    private func handleRegistrationCallback() async {
        guard let registrationCallbackURL else {
            return
        }
        do {
            try await wearables.handleRegistrationCallback(registrationCallbackURL)
            await refreshPermissionStatus()
        } catch let error as any LocalizedError {
            Logger.wearables.error("Unable to complete camera permission request: \(error.localizedDescription)")
            viewState = .error(error)
        } catch {
            Logger.wearables.error("Unable to complete camera permission request: \(error.localizedDescription)")
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }
}


#Preview("Camera Permission", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        GlassesCameraPermissionOnboardingView(
            configuration: .preview(glassesSource: .simulatedGlasses, analysisSource: .sampleAnalysis)
        )
        .environment(WearablesCoordinator())
    }
}
