//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutritionResultHeaderView: View {
    let analysis: NutritionAnalysis
    let capturedImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 18))
                    .accessibilityLabel(.capturedMealPhoto)
            }
            Text(analysis.title)
                .font(.largeTitle)
                .bold()
                .accessibilityHeading(.h1)
                .accessibilityIdentifier("nutrition-title")
            Text(analysis.summary)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Label {
                Text(analysis.confidence, format: .percent.precision(.fractionLength(0)))
            } icon: {
                Image(systemName: "checkmark.seal")
            }
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(.modelConfidence)
            .accessibilityValue(Text(analysis.confidence, format: .percent.precision(.fractionLength(0))))
        }
        .padding(.vertical)
    }
}


#if DEBUG
#Preview("Nutrition Result Header") {
    ScrollView {
        NutritionResultHeaderView(
            analysis: .cheeseSpaetzleFixture,
            capturedImage: PreviewAssets.cheeseSpaetzle
        )
        .padding()
    }
}
#endif
