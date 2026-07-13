//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
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

    @State private var showsSaveConfirmation = false

    var body: some View {
        List {
            resultSections
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background(.regularMaterial)
        .padding(.top, -24)
        .alert(saveConfirmationTitle, isPresented: $showsSaveConfirmation) {
        } message: {
            Text(saveConfirmationMessage)
        }
        .sensoryFeedback(.success, trigger: showsSaveConfirmation) { _, isPresented in
            isPresented
        }
    }

    @ViewBuilder private var resultSections: some View {
        NutritionResultHeaderView(analysis: analysis, capturedImage: capturedImage)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            .listRowSeparator(.hidden)

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

        actionsSection
    }

    private var actionsSection: some View {
        Section {
            NutritionResultActionsView(
                model: model,
                configuration: configuration,
                saveAction: save,
                analyzeAnotherAction: closeAction
            )
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 24, trailing: 0))
            .listRowSeparator(.hidden)
        }
    }

    private var saveConfirmationTitle: LocalizedStringResource {
        configuration.usesMockHealthKit ? .simulatedSaveComplete : .savedToAppleHealth
    }

    private var saveConfirmationMessage: LocalizedStringResource {
        configuration.usesMockHealthKit ? .simulatedSaveSuccessMessage : .healthSaveSuccessMessage
    }

    private func sectionHeader(_ title: LocalizedStringResource) -> some View {
        Text(title)
            .font(.headline)
            .textCase(nil)
            .accessibilityIdentifier("nutrition-section-header")
    }

    private func save() async throws {
        if configuration.usesMockHealthKit {
            try await model.save(using: MockNutritionHealthStore())
        } else {
            try await model.save(using: HealthKitNutritionStore(healthKit: healthKit))
        }
        showsSaveConfirmation = true
    }
}


#Preview("Nutrition Result · Complete Composition", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var model = CaptureFeatureModel(
        previewWorkflowState: .result,
        analysis: .cheeseSpaetzleFixture
    )
    @Previewable @State var configuration = ExperienceConfiguration.preview(
        glassesSource: .simulatedGlasses,
        analysisSource: .sampleAnalysis
    )

    NutritionResultView(
        model: model,
        configuration: configuration,
        analysis: .cheeseSpaetzleFixture,
        capturedImage: PreviewAssets.cheeseSpaetzle,
        closeAction: {}
    )
    .previewWith(standard: NutriSightStandard()) {
        SpeziHealthKit.HealthKit {
            RequestWriteAccess(quantity: NutritionHealthKitTypes.writable)
        }
    }
}


#Preview("Nutrition Result · Saved", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var model = CaptureFeatureModel(
        previewWorkflowState: .saved,
        analysis: .cheeseSpaetzleFixture
    )
    @Previewable @State var configuration = ExperienceConfiguration.preview(
        glassesSource: .simulatedGlasses,
        analysisSource: .sampleAnalysis
    )

    NavigationStack {
        NutritionResultView(
            model: model,
            configuration: configuration,
            analysis: .cheeseSpaetzleFixture,
            capturedImage: PreviewAssets.cheeseSpaetzle,
            closeAction: {}
        )
        .navigationBarTitleDisplayMode(.inline)
    }
    .previewWith(standard: NutriSightStandard()) {
        SpeziHealthKit.HealthKit {
            RequestWriteAccess(quantity: NutritionHealthKitTypes.writable)
        }
    }
}
