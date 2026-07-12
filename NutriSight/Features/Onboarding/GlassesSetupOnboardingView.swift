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
    @State private var pairingTask: Task<Void, Never>?

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
            VStack(spacing: 10) {
                Button(action: startPairing) {
                    Label {
                        Text(isPairing ? "Pairing…" : String(localized: .pairMetaGlasses))
                            .multilineTextAlignment(.center)
                    } icon: {
                        if isPairing {
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(isPairing)
                .accessibilityIdentifier("pair-meta-glasses")

                if isPairing {
                    Button(role: .destructive, action: cancelPairing) {
                        Text("Cancel Pairing")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .tint(.red)
                    .accessibilityIdentifier("cancel-pairing")
                } else if LaunchConfiguration.allowsSimulatedGlasses {
                    AsyncButton(state: $viewState, action: useSimulatedGlasses) {
                        Text(.useSimulatedGlasses)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .accessibilityIdentifier("use-simulated-glasses")

                    Text(.simulatedGlassesExplanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    AsyncButton(state: $viewState, action: usePhoneCamera) {
                        Text("Use iPhone Camera")
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .accessibilityIdentifier("use-phone-camera")

                    Text("Allow camera access to capture meals with this iPhone when Meta glasses are not connected.")
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
        .onOpenURL(perform: handleWearablesURL)
        .onChange(of: wearables.state) {
            guard isPairing, wearables.isRegistered else {
                return
            }
            completeMetaGlassesPairing()
        }
    }

    private func startPairing() {
        guard !isPairing else {
            return
        }
        isPairing = true
        viewState = .idle
        pairingTask = Task {
            do {
                try await pairMetaGlasses()
                guard wearables.isRegistered else {
                    pairingTask = nil
                    return
                }
                completeMetaGlassesPairing()
            } catch is CancellationError {
                pairingTask = nil
            } catch let error as any LocalizedError {
                isPairing = false
                pairingTask = nil
                viewState = .error(error)
            } catch {
                isPairing = false
                pairingTask = nil
                viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
            }
        }
    }

    private func pairMetaGlasses() async throws {
        try await wearables.selectSource(.metaGlasses)
        guard !wearables.isRegistered else {
            return
        }
        try await wearables.pair()
    }

    private func cancelPairing() {
        pairingTask?.cancel()
        pairingTask = nil
        isPairing = false
        viewState = .idle
    }

    private func completeMetaGlassesPairing() {
        guard isPairing else {
            return
        }
        configuration.selectGlassesSource(.metaGlasses)
        isPairing = false
        pairingTask = nil
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

    private func handleWearablesURL(_ url: URL) {
        guard url.isMetaWearablesCallback else {
            return
        }
        isPairing = true
        viewState = .idle
        Task {
            do {
                try await wearables.handleRegistrationCallback(url)
                guard wearables.isRegistered else {
                    isPairing = false
                    pairingTask = nil
                    return
                }
                completeMetaGlassesPairing()
            } catch let error as any LocalizedError {
                Logger.wearables.error("Unable to complete Meta Wearables registration: \(error.localizedDescription)")
                isPairing = false
                pairingTask = nil
                viewState = .error(error)
            } catch {
                Logger.wearables.error("Unable to complete Meta Wearables registration: \(error.localizedDescription)")
                isPairing = false
                pairingTask = nil
                viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
            }
        }
    }
}


#Preview("Glasses Setup") {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        GlassesSetupOnboardingView(configuration: .preview(analysisSource: .sampleAnalysis))
            .environment(WearablesCoordinator())
    }
}
