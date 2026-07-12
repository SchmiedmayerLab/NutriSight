//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum WearablesBootstrapError: LocalizedError {
    case missingSimulatedMedia
    case sourceAlreadySelected
    case sdk(String)

    var errorDescription: String? {
        switch self {
        case .missingSimulatedMedia:
            String(localized: .errorMissingSimulatedMedia)
        case .sourceAlreadySelected:
            String(localized: .errorWearablesSourceAlreadySelected)
        case .sdk(let description):
            description
        }
    }
}
