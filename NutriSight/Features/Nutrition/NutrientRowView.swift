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
        LabeledContent {
            Text(verbatim: nutrient.kind.formattedAmount(nutrient.amount))
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            Text(nutrient.kind.displayName)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("nutrient-\(nutrient.kind.rawValue)")
    }
}


#if DEBUG
#Preview("Nutrient Row") {
    List {
        NutrientRowView(nutrient: NutrientValue(kind: .protein, amount: 31))
    }
}
#endif
