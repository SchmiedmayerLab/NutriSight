//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct OnboardingHeroPreview: Identifiable {
    static let allCases = [
        OnboardingHeroPreview(
            id: "welcome",
            systemImage: "camera.viewfinder",
            title: .welcomeTitle,
            subtitle: .welcomeSubtitle
        ),
        OnboardingHeroPreview(
            id: "analysis",
            systemImage: "sparkles.rectangle.stack",
            title: .analysisSetupTitle,
            subtitle: .analysisSetupSubtitle
        ),
        OnboardingHeroPreview(
            id: "glasses",
            systemImage: "eyeglasses",
            title: .glassesSetupTitle,
            subtitle: .glassesSetupSubtitle
        )
    ]

    let id: String
    let systemImage: String
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource
}


struct OnboardingHeroView: View {
    let systemImage: String
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 84, height: 84)
                .background(.tint.opacity(0.12), in: .circle)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.leading)
                    .accessibilityHeading(.h1)
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 12)
        .padding(.bottom, 22)
    }
}


#Preview("Onboarding Heroes", arguments: OnboardingHeroPreview.allCases) { preview in
    OnboardingHeroView(
        systemImage: preview.systemImage,
        title: preview.title,
        subtitle: preview.subtitle
    )
    .padding()
}
