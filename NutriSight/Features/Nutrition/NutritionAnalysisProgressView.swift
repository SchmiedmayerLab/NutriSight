//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionAnalysisProgressView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let configuration: ExperienceConfiguration
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource

    @State private var animatesAnalysis = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.title2.weight(.semibold))
                    .symbolEffect(.pulse, options: .repeating, value: animatesAnalysis)
                    .frame(width: 52, height: 52)
                    .background(.tint.opacity(0.14), in: .circle)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title2.bold())
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ProgressView(value: animatesAnalysis ? 0.72 : 0.18)
                .progressViewStyle(.linear)
                .animation(reduceMotion ? nil : .smooth(duration: 1.6).repeatForever(autoreverses: true), value: animatesAnalysis)

            if configuration.usesSampleAnalysis {
                Label(.sampleAnalysisActive, systemImage: "wand.and.stars")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("analysis-progress")
        .onAppear {
            animatesAnalysis = true
        }
    }
}


#Preview("Sample Analysis Progress") {
    NutritionAnalysisProgressView(
        configuration: .preview(glassesSource: .simulatedGlasses, analysisSource: .sampleAnalysis),
        title: .analyzingYourMeal,
        subtitle: .analysisInProgress
    )
    .presentationBackground(.regularMaterial)
}
