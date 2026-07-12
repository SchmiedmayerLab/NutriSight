//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct FoodItemsView: View {
    let items: [FoodItem]

    var body: some View {
        ForEach(items) { item in
            LabeledContent {
                Text(item.estimatedPortion)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            } label: {
                Text(item.name)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
        }
    }
}


#if DEBUG
#Preview("Detected Foods") {
    List {
        Section(.foods) {
            FoodItemsView(items: NutritionAnalysis.cheeseSpaetzleFixture.items)
        }
    }
}
#endif
