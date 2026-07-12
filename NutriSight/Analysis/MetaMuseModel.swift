//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMOpenAI


struct MetaMuseModel: LLMOpenAILikePlatformModelType {
    static let museSpark11: Self = "muse-spark-1.1"
    static let `default`: Self = .museSpark11
    static let wellKnownModels: [Self] = [.museSpark11]

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
