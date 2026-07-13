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
        Group {
            if let capturedImage {
                ZStack(alignment: .bottom) {
                    Color.secondary.opacity(0.12)
                    Image(uiImage: capturedImage)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .accessibilityLabel(.capturedMealPhoto)
                    NutritionResultSummaryOverlay(analysis: analysis)
                        .padding(12)
                }
                .clipShape(.rect(cornerRadius: 22))
            } else {
                NutritionResultSummaryOverlay(analysis: analysis)
            }
        }
        .accessibilityElement(children: .contain)
    }
}


#Preview("Nutrition Result Header · With Photo", traits: .fixedLayout(width: 402, height: 560)) {
    ScrollView {
        NutritionResultHeaderView(
            analysis: .cheeseSpaetzleFixture,
            capturedImage: PreviewAssets.cheeseSpaetzle
        )
        .padding()
    }
}


#Preview("Nutrition Result Header · Text Only", traits: .sizeThatFitsLayout) {
    NutritionResultHeaderView(
        analysis: .cheeseSpaetzleFixture,
        capturedImage: nil
    )
    .padding()
}
