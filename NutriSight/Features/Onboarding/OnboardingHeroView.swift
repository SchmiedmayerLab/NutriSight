//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


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


#Preview("Hero · Welcome", traits: .fixedLayout(width: 320, height: 330)) {
    OnboardingHeroView(
        systemImage: "camera.viewfinder",
        title: .welcomeTitle,
        subtitle: .welcomeSubtitle
    )
    .padding()
}


#Preview("Hero · Analysis", traits: .fixedLayout(width: 320, height: 330)) {
    OnboardingHeroView(
        systemImage: "sparkles.rectangle.stack",
        title: .analysisSetupTitle,
        subtitle: .analysisSetupSubtitle
    )
    .padding()
}


#Preview("Hero · Glasses", traits: .fixedLayout(width: 320, height: 330)) {
    OnboardingHeroView(
        systemImage: "eyeglasses",
        title: .glassesSetupTitle,
        subtitle: .glassesSetupSubtitle
    )
    .padding()
}


#Preview("Hero · Permission", traits: .fixedLayout(width: 320, height: 330)) {
    OnboardingHeroView(
        systemImage: "camera.badge.ellipsis",
        title: .cameraPermissionTitle,
        subtitle: .cameraPermissionSubtitle
    )
    .padding()
}
