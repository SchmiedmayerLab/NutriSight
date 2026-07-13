//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

extension NutritionAnalysis {
    static let cheeseSpaetzleFixture = NutritionAnalysis(
        title: "Käsespätzle with Salad",
        summary: "A large plate of cheese spaetzle with caramelized onions and chives, served with a mixed salad and a dark cola-orange soft drink.",
        items: [
            FoodItem(name: "Cheese spaetzle", estimatedPortion: "about 2 1/2 cups"),
            FoodItem(name: "Caramelized onions and chives", estimatedPortion: "about 1/3 cup"),
            FoodItem(name: "Mixed leaf salad with carrot, tomato, and dressing", estimatedPortion: "about 1 1/2 cups"),
            FoodItem(name: "Cola-orange soft drink", estimatedPortion: "about 300 mL")
        ],
        nutrients: [
            NutrientValue(kind: .energy, amount: 1_120),
            NutrientValue(kind: .protein, amount: 34),
            NutrientValue(kind: .carbohydrates, amount: 142),
            NutrientValue(kind: .totalFat, amount: 47),
            NutrientValue(kind: .saturatedFat, amount: 23),
            NutrientValue(kind: .fiber, amount: 8),
            NutrientValue(kind: .sugar, amount: 43),
            NutrientValue(kind: .sodium, amount: 1_680),
            NutrientValue(kind: .cholesterol, amount: 145),
            NutrientValue(kind: .potassium, amount: 920),
            NutrientValue(kind: .calcium, amount: 710),
            NutrientValue(kind: .iron, amount: 5.2)
        ],
        confidence: 0.87,
        caveats: [
            "The amount and type of cheese, butter, salad dressing, and sweetener in the drink cannot be confirmed from the photo.",
            "Portion sizes are estimated from the visible dishes and glass.",
            "Review all estimates before saving them to Apple Health."
        ]
    )
}
