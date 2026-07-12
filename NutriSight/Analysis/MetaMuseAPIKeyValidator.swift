//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum MetaMuseAPIKeyValidationError: LocalizedError {
    case empty
    case rejected
    case unavailable(Int)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .empty:
            "Enter a Meta Model API key before continuing."
        case .rejected:
            "Meta rejected this API key. Check the key and try again."
        case let .unavailable(statusCode):
            "Meta could not validate the API key right now. The request returned HTTP \(statusCode)."
        case .invalidResponse:
            "Meta returned an unexpected response while validating the API key."
        }
    }
}


enum MetaMuseAPIKeyValidator {
    static func validate(_ apiKey: String) async throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            throw MetaMuseAPIKeyValidationError.empty
        }
        guard !LaunchConfiguration.usesMockLLM else {
            return
        }

        var request = URLRequest(url: MetaMusePlatformDefinition.defaultServerUrl.appending(path: "models"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MetaMuseAPIKeyValidationError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401, 403:
            throw MetaMuseAPIKeyValidationError.rejected
        default:
            throw MetaMuseAPIKeyValidationError.unavailable(httpResponse.statusCode)
        }
    }
}
