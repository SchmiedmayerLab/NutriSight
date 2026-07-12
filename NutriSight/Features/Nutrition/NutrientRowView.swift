//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutrientRowView: View {
    let nutrient: NutrientValue

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                nutrientName
                Spacer(minLength: 12)
                amount
                    .multilineTextAlignment(.trailing)
            }

            VStack(alignment: .leading, spacing: 4) {
                nutrientName
                amount
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("nutrient-\(nutrient.kind.rawValue)")
    }

    private var nutrientName: some View {
        Text(nutrient.kind.displayName)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var amount: some View {
        Text(verbatim: nutrient.kind.formattedAmount(nutrient.amount))
            .foregroundStyle(.secondary)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}


#Preview("Nutrient Row") {
    List {
        NutrientRowView(nutrient: NutrientValue(kind: .protein, amount: 31))
    }
}
