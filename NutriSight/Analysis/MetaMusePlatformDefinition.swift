//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziKeychainStorage
import SpeziLLMOpenAI


typealias MetaMusePlatform = LLMOpenAILikePlatform<MetaMusePlatformDefinition>
typealias MetaMuseSchema = LLMOpenAILikeSchema<MetaMusePlatformDefinition>


enum MetaMusePlatformDefinition: LLMOpenAILikePlatformDefinition {
    typealias ModelType = MetaMuseModel

    static let platformName = "Meta Model API"
    static var defaultServerUrl: URL {
        guard let url = URL(string: "https://api.meta.ai/v1") else {
            fatalError("The static Meta Model API URL is invalid.")
        }
        return url
    }
    static let platformServiceIdentifier = "api.meta.ai"
    static let platformDeveloperConsoleUrl = URL(string: "https://dev.meta.ai")
    static let credentialsTag = CredentialsTag.for(Self.self)
    static let credentialsUsername = "\(platformName)_Token"
}
