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
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    itemName(item.name)
                    Spacer(minLength: 12)
                    portion(item.estimatedPortion)
                        .multilineTextAlignment(.trailing)
                }

                VStack(alignment: .leading, spacing: 4) {
                    itemName(item.name)
                    portion(item.estimatedPortion)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func itemName(_ name: String) -> some View {
        Text(name)
            .font(.body)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func portion(_ portion: String) -> some View {
        Text(portion)
            .font(.body)
            .foregroundStyle(.secondary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}


#Preview("Detected Foods") {
    List {
        Section(.foods) {
            FoodItemsView(items: NutritionAnalysis.cheeseSpaetzleFixture.items)
        }
    }
}
