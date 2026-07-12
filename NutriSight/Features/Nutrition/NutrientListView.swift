//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NutrientListView: View {
    let nutrients: [NutrientValue]

    var body: some View {
        ForEach(nutrients) { nutrient in
            NutrientRowView(nutrient: nutrient)
        }
    }
}


#if DEBUG
#Preview("Estimated Nutrition") {
    List {
        Section(.estimatedNutrition) {
            NutrientListView(nutrients: NutritionAnalysis.cheeseSpaetzleFixture.nutrients)
        }
    }
}
#endif
