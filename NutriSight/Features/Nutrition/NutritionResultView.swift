//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziHealthKit
import SpeziViews
import SwiftUI


struct NutritionResultView: View {
    @Environment(SpeziHealthKit.HealthKit.self) private var healthKit
    @Bindable var model: CaptureFeatureModel
    @Bindable var configuration: ExperienceConfiguration
    let analysis: NutritionAnalysis
    let capturedImage: UIImage?
    let closeAction: () -> Void

    var body: some View {
        List {
            NutritionResultHeaderView(analysis: analysis, capturedImage: capturedImage)
                .listRowBackground(Color.clear)

            Section {
                FoodItemsView(items: analysis.items)
            } header: {
                sectionHeader(.foods)
            }

            Section {
                NutrientListView(nutrients: analysis.nutrients)
            } header: {
                sectionHeader(.estimatedNutrition)
            }

            if !analysis.caveats.isEmpty {
                Section {
                    ForEach(analysis.caveats, id: \.self) { caveat in
                        Label(caveat, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } header: {
                    sectionHeader(.beforeYouSave)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(.regularMaterial)
        .safeAreaInset(edge: .bottom) {
            NutritionResultActionsView(
                model: model,
                configuration: configuration,
                saveAction: save,
                analyzeAnotherAction: closeAction
            )
            .padding()
        }
    }

    private func sectionHeader(_ title: LocalizedStringResource) -> some View {
        Text(title)
            .font(.headline)
            .textCase(nil)
            .accessibilityIdentifier("nutrition-section-header")
    }

    private func save() async throws {
        if configuration.preventsAppleHealthWrite {
            try await model.save(using: MockNutritionHealthStore())
        } else {
            try await model.save(using: HealthKitNutritionStore(healthKit: healthKit))
        }
    }
}
