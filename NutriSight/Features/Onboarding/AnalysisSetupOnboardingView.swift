//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziKeychainStorage
import SpeziLLMOpenAI
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct AnalysisSetupOnboardingView: View {
    @Environment(KeychainStorage.self) private var keychainStorage
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Bindable var configuration: ExperienceConfiguration

    @State private var apiKey = ""
    @State private var viewState: ViewState = .idle
    @FocusState private var apiKeyFieldIsFocused: Bool

    var body: some View {
        OnboardingView {
            OnboardingHeroView(
                systemImage: "sparkles.rectangle.stack",
                title: .analysisSetupTitle,
                subtitle: .analysisSetupSubtitle
            )
        } content: {
            VStack(alignment: .leading, spacing: 16) {
                SecureField(.metaApiKeyPrompt, text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($apiKeyFieldIsFocused)
                    .accessibilityIdentifier("meta-api-key-field")
                Label(.apiKeyStoredSecurely, systemImage: "lock.shield")
                    .font(.footnote)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                MetaDeveloperConsoleLink()
            }
        } footer: {
            VStack(spacing: 10) {
                AsyncButton(state: $viewState, action: saveAndContinue) {
                    Text(.continueWithMetaModel)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("save-api-key")

                if LaunchConfiguration.allowsSampleAnalysis {
                    AsyncButton(state: $viewState, action: useSampleAnalysis) {
                        Text(.useSampleAnalysis)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    .accessibilityIdentifier("use-sample-analysis")

                    Text(.sampleAnalysisExplanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .viewStateAlert(state: $viewState)
        }
        .contentShape(.rect)
        .onTapGesture {
            apiKeyFieldIsFocused = false
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            loadStoredAPIKey()
        }
    }

    private func loadStoredAPIKey() {
        if LaunchConfiguration.resetsAPIKey && !LaunchConfiguration.hasResetAPIKey {
            try? keychainStorage.deleteCredentials(
                withUsername: MetaMusePlatformDefinition.credentialsUsername,
                for: MetaMusePlatformDefinition.credentialsTag
            )
            LaunchConfiguration.markAPIKeyReset()
        }
        apiKey = (try? keychainStorage.retrieveCredentials(
            withUsername: MetaMusePlatformDefinition.credentialsUsername,
            for: MetaMusePlatformDefinition.credentialsTag
        )?.password) ?? ""
    }

    private func saveAndContinue() async throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        try await MetaMuseAPIKeyValidator.validate(trimmedKey)
        try keychainStorage.store(
            Credentials(username: MetaMusePlatformDefinition.credentialsUsername, password: trimmedKey),
            for: MetaMusePlatformDefinition.credentialsTag,
            replaceDuplicates: true
        )
        configuration.selectAnalysisSource(.metaModel)
        path.nextStep()
    }

    private func useSampleAnalysis() async {
        configuration.selectAnalysisSource(.sampleAnalysis)
        path.nextStep()
    }
}


#Preview("Analysis Setup") {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        AnalysisSetupOnboardingView(configuration: .preview())
    }
    .previewWith {
        KeychainStorage()
    }
}
