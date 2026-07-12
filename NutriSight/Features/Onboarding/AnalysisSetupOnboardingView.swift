//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
                    .accessibilityIdentifier("meta-api-key-field")
                Label(.apiKeyStoredSecurely, systemImage: "lock.shield")
                    .font(.footnote)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                MetaDeveloperConsoleLink()
            }
        } footer: {
            VStack(spacing: 8) {
                AsyncButton(.continueWithMetaModel, state: $viewState, action: saveAndContinue)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("save-api-key")
                Button(.useSampleAnalysis, action: useSampleAnalysis)
                    .controlSize(.large)
                    .accessibilityIdentifier("use-sample-analysis")
                Text(.sampleAnalysisExplanation)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .viewStateAlert(state: $viewState)
        }
        .navigationTitle(.mealAnalysis)
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

    private func saveAndContinue() throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        try keychainStorage.store(
            Credentials(username: MetaMusePlatformDefinition.credentialsUsername, password: trimmedKey),
            for: MetaMusePlatformDefinition.credentialsTag,
            replaceDuplicates: true
        )
        configuration.selectAnalysisSource(.metaModel)
        path.nextStep()
    }

    private func useSampleAnalysis() {
        configuration.selectAnalysisSource(.sampleAnalysis)
        path.nextStep()
    }
}


#if DEBUG
#Preview("Analysis Setup") {
    @Previewable @State var didComplete = false
    @Previewable @State var path = ManagedNavigationStack.Path()

    ManagedNavigationStack(didComplete: $didComplete, path: path) {
        AnalysisSetupOnboardingView(configuration: .preview())
    }
    .environment(KeychainStorage())
}
#endif
