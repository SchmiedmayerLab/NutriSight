//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionAnalysisProgressView: View {
    let configuration: ExperienceConfiguration
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .bold()
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }
            }
            if configuration.usesSampleAnalysis {
                Label(.sampleAnalysisActive, systemImage: "wand.and.stars")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("analysis-progress")
    }
}


#if DEBUG
#Preview("Sample Analysis Progress") {
    NutritionAnalysisProgressView(
        configuration: .preview(glassesSource: .simulatedGlasses, analysisSource: .sampleAnalysis),
        title: .analyzingYourMeal,
        subtitle: .analysisInProgress
    )
    .presentationBackground(.ultraThinMaterial)
}
#endif
