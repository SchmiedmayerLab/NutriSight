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
import SwiftUI


struct MetaAPIKeySetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(KeychainStorage.self) private var keychainStorage

    @State private var apiKey = ""

    var body: some View {
        NavigationStack {
            OnboardingView {
                OnboardingTitleView(title: .metaApiKey, subtitle: .metaApiKeySubtitle)
            } content: {
                VStack(spacing: 20) {
                    SecureField(.metaApiKeyPrompt, text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("meta-api-key-field")

                    Text(.metaApiKeyFootnote)
                        .font(.footnote)

                    MetaDeveloperConsoleLink()
                }
            } footer: {
                OnboardingActionsView(.saveApiKey, action: save)
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("save-api-key")
            }
            .navigationTitle(.museSpark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.close, systemImage: "xmark", action: dismiss.callAsFunction)
                        .accessibilityIdentifier("close-api-key")
                }
            }
            .task {
                loadStoredAPIKey()
            }
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

    private func save() throws {
        try keychainStorage.store(
            Credentials(username: MetaMusePlatformDefinition.credentialsUsername, password: apiKey),
            for: MetaMusePlatformDefinition.credentialsTag,
            replaceDuplicates: true
        )
        dismiss()
    }
}
