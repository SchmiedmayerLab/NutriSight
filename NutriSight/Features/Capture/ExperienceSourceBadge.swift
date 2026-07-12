//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ExperienceSourceBadge: View {
    let title: LocalizedStringResource
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline)
            .bold()
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("experience-source")
    }
}


#Preview("Sample Analysis Badge") {
    ExperienceSourceBadge(title: .sampleAnalysis, systemImage: "wand.and.stars")
        .padding()
}
