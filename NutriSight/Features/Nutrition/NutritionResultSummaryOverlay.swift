//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionResultSummaryOverlay: View {
    let analysis: NutritionAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(analysis.title)
                .font(.title.bold())
                .lineLimit(2)
                .accessibilityHeading(.h1)
                .accessibilityIdentifier("nutrition-title")
            Text(analysis.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
            Label {
                Text(analysis.confidence, format: .percent.precision(.fractionLength(0)))
            } icon: {
                Image(systemName: "checkmark.seal")
            }
            .font(.subheadline.bold())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(.modelConfidence)
            .accessibilityValue(Text(analysis.confidence, format: .percent.precision(.fractionLength(0))))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
    }
}


#Preview("Result Summary Overlay", traits: .fixedLayout(width: 360, height: 210)) {
    NutritionResultSummaryOverlay(analysis: .cheeseSpaetzleFixture)
        .padding()
        .background(PreviewAssets.cheeseSpaetzle.map(Image.init(uiImage:))?.resizable().scaledToFill())
}
