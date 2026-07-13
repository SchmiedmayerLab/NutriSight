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

    var usesPhoneCamera: Bool {
        glassesSource == .phoneCamera
    }

    var usesSampleAnalysis: Bool {
        analysisSource == .sampleAnalysis
    }

    var usesMockHealthKit: Bool {
        LaunchConfiguration.usesMockHealthKit
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.completedOnboarding = defaults.bool(forKey: Key.completedOnboarding)
        self.glassesSource = defaults.string(forKey: Key.glassesSource).flatMap(GlassesSource.init(rawValue:))
        self.analysisSource = defaults.string(forKey: Key.analysisSource).flatMap(AnalysisSource.init(rawValue:))
        sanitizeUnavailableSources()

        if LaunchConfiguration.isUITesting && completedOnboarding {
            glassesSource = .simulatedGlasses
            analysisSource = .sampleAnalysis
        }
    }

    func selectAnalysisSource(_ source: AnalysisSource) {
        precondition(source != .sampleAnalysis || LaunchConfiguration.allowsSampleAnalysis)
        analysisSource = source
        defaults.set(source.rawValue, forKey: Key.analysisSource)
    }

    func selectGlassesSource(_ source: GlassesSource) {
        precondition(source != .simulatedGlasses || LaunchConfiguration.allowsSimulatedGlasses)
        glassesSource = source
        defaults.set(source.rawValue, forKey: Key.glassesSource)
    }

    func completeOnboarding() {
        precondition(glassesSource != nil && analysisSource != nil)
        completedOnboarding = true
        defaults.set(true, forKey: Key.completedOnboarding)
    }

    private func sanitizeUnavailableSources() {
        if analysisSource == .sampleAnalysis && !LaunchConfiguration.allowsSampleAnalysis {
            analysisSource = nil
            defaults.removeObject(forKey: Key.analysisSource)
        }
        if glassesSource == .simulatedGlasses && !LaunchConfiguration.allowsSimulatedGlasses {
            glassesSource = nil
            defaults.removeObject(forKey: Key.glassesSource)
            completedOnboarding = false
            defaults.set(false, forKey: Key.completedOnboarding)
        }
    }
}
