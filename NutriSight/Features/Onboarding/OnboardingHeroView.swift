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
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.largeTitle.scaled(by: 1.45))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .frame(width: 88, height: 88)
                .background(.tint.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            Text(title)
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .accessibilityHeading(.h1)
            Text(subtitle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }
}


#if DEBUG
#Preview("Onboarding Hero") {
    OnboardingHeroView(
        systemImage: "camera.viewfinder",
        title: .welcomeTitle,
        subtitle: .welcomeSubtitle
    )
    .padding()
}
#endif
