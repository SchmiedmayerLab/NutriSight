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


struct MetaAPIKeySetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(KeychainStorage.self) private var keychainStorage

    @State private var apiKey = ""
    @State private var viewState: ViewState = .idle

    var body: some View {
        NavigationStack {
            OnboardingView {
                OnboardingHeroView(systemImage: "key.fill", title: .metaApiKey, subtitle: .metaApiKeySubtitle)
            } content: {
                setupContent
            } footer: {
                footer
            }
            .navigationTitle(.museSpark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                closeToolbarItem
            }
            .task {
                loadStoredAPIKey()
            }
        }
    }

    private var setupContent: some View {
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
    }

    private var footer: some View {
        AsyncButton(state: $viewState, action: save) {
            Text(.saveApiKey)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .accessibilityIdentifier("save-api-key")
        .viewStateAlert(state: $viewState)
    }

    private var closeToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(.close, systemImage: "xmark", action: dismiss.callAsFunction)
                .accessibilityIdentifier("close-api-key")
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


#Preview("Meta API Key Setup") {
    MetaAPIKeySetupView()
        .previewWith {
            KeychainStorage()
        }
}
