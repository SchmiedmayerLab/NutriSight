//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//
import Spezi
import SpeziHealthKit
import SpeziKeychainStorage
import SpeziLLM
import SpeziLLMOpenAI
import UIKit


class NutriSightAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: NutriSightStandard()) {
            WearablesCoordinator()
            KeychainStorage()
            LLMRunner {
                MetaMusePlatform(
                    configuration: .init(
                        authToken: .keychain(for: MetaMusePlatform.self),
                        concurrentStreams: 1,
                        timeout: 90
                    )
                )
            }
            SpeziHealthKit.HealthKit {
                RequestWriteAccess(quantity: NutritionHealthKitTypes.writable)
            }
        }
    }
}
