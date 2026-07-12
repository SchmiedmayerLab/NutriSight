//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

extension NutritionAnalysis {
    static let cheeseSpaetzleFixture = NutritionAnalysis(
        title: "Käsespätzle",
        summary: "Cheese spaetzle topped with fried onions, parsley, and a roasted tomato.",
        items: [
            FoodItem(name: "Cheese spaetzle", estimatedPortion: "about 2 cups"),
            FoodItem(name: "Fried onions", estimatedPortion: "about 1/4 cup"),
            FoodItem(name: "Roasted tomato and parsley", estimatedPortion: "small garnish")
        ],
        nutrients: [
            NutrientValue(kind: .energy, amount: 780),
            NutrientValue(kind: .protein, amount: 29),
            NutrientValue(kind: .carbohydrates, amount: 88),
            NutrientValue(kind: .totalFat, amount: 34),
            NutrientValue(kind: .saturatedFat, amount: 18),
            NutrientValue(kind: .fiber, amount: 5),
            NutrientValue(kind: .sugar, amount: 7),
            NutrientValue(kind: .sodium, amount: 1_450),
            NutrientValue(kind: .cholesterol, amount: 125),
            NutrientValue(kind: .potassium, amount: 520),
            NutrientValue(kind: .calcium, amount: 620),
            NutrientValue(kind: .iron, amount: 4.1)
        ],
        confidence: 0.82,
        caveats: [
            "Portion sizes and preparation methods cannot be confirmed from a photo.",
            "Review all estimates before saving them to Apple Health."
        ]
    )
}
