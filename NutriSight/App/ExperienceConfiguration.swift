//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Observation


@MainActor
@Observable
final class ExperienceConfiguration {
    private enum Key {
        static let completedOnboarding = "completedOnboarding"
        static let glassesSource = "glassesSource"
        static let analysisSource = "analysisSource"
    }

    private let defaults: UserDefaults

    private(set) var glassesSource: GlassesSource?
    private(set) var analysisSource: AnalysisSource?
    private(set) var completedOnboarding: Bool

    var usesSimulatedGlasses: Bool {
        glassesSource == .simulatedGlasses
    }

    var usesSampleAnalysis: Bool {
        analysisSource == .sampleAnalysis
    }

    var preventsAppleHealthWrite: Bool {
        usesSimulatedGlasses || usesSampleAnalysis
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.completedOnboarding = defaults.bool(forKey: Key.completedOnboarding)
        self.glassesSource = defaults.string(forKey: Key.glassesSource).flatMap(GlassesSource.init(rawValue:))
        self.analysisSource = defaults.string(forKey: Key.analysisSource).flatMap(AnalysisSource.init(rawValue:))

        if LaunchConfiguration.isUITesting {
            glassesSource = .simulatedGlasses
            analysisSource = .sampleAnalysis
        }
    }

    static func persistedGlassesSource(defaults: UserDefaults = .standard) -> GlassesSource? {
        if LaunchConfiguration.isUITesting {
            return .simulatedGlasses
        }
        return defaults.string(forKey: Key.glassesSource).flatMap(GlassesSource.init(rawValue:))
    }

    func selectAnalysisSource(_ source: AnalysisSource) {
        analysisSource = source
        defaults.set(source.rawValue, forKey: Key.analysisSource)
    }

    func selectGlassesSource(_ source: GlassesSource) {
        glassesSource = source
        defaults.set(source.rawValue, forKey: Key.glassesSource)
    }

    func completeOnboarding() {
        precondition(glassesSource != nil && analysisSource != nil)
        completedOnboarding = true
        defaults.set(true, forKey: Key.completedOnboarding)
    }
}
