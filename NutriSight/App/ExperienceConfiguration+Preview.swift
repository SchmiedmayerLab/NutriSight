//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if DEBUG
import Foundation


extension ExperienceConfiguration {
    static func preview(
        glassesSource: GlassesSource? = nil,
        analysisSource: AnalysisSource? = nil
    ) -> ExperienceConfiguration {
        let suiteName = "edu.stanford.nutrisight.previews"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        let configuration = ExperienceConfiguration(defaults: defaults)
        if let glassesSource {
            configuration.selectGlassesSource(glassesSource)
        }
        if let analysisSource {
            configuration.selectAnalysisSource(analysisSource)
        }
        return configuration
    }
}
#endif
