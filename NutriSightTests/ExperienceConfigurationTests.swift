//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import NutriSight
import Testing


@MainActor
@Suite("Experience configuration")
struct ExperienceConfigurationTests {
    @Test("Persists independent analysis and glasses choices")
    func persistsChoices() throws {
        let defaults = try #require(UserDefaults(suiteName: "ExperienceConfigurationTests-persistence"))
        defaults.removePersistentDomain(forName: "ExperienceConfigurationTests-persistence")

        let configuration = ExperienceConfiguration(defaults: defaults)
        configuration.selectAnalysisSource(.metaModel)
        configuration.selectGlassesSource(.simulatedGlasses)
        configuration.completeOnboarding()

        let restored = ExperienceConfiguration(defaults: defaults)
        #expect(restored.analysisSource == .metaModel)
        #expect(restored.glassesSource == .simulatedGlasses)
        #expect(restored.completedOnboarding)
    }

    @Test(
        "Camera and analysis sources do not disable Apple Health writes",
        arguments: [
            (GlassesSource.simulatedGlasses, AnalysisSource.metaModel),
            (GlassesSource.metaGlasses, AnalysisSource.sampleAnalysis),
            (GlassesSource.simulatedGlasses, AnalysisSource.sampleAnalysis),
            (GlassesSource.metaGlasses, AnalysisSource.metaModel)
        ]
    )
    func healthWriteAvailability(glasses: GlassesSource, analysis: AnalysisSource) throws {
        let suiteName = "ExperienceConfigurationTests-\(glasses.rawValue)-\(analysis.rawValue)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        let configuration = ExperienceConfiguration(defaults: defaults)

        configuration.selectGlassesSource(glasses)
        configuration.selectAnalysisSource(analysis)

        #expect(!configuration.usesMockHealthKit)
    }
}
