//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//
import OSLog
import Spezi
import SpeziHealthKit
import SpeziKeychainStorage
import SpeziLLM
import SpeziLLMOpenAI
import UIKit


class NutriSightAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: NutriSightStandard()) {
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

    override init() {
        super.init()
        if let source = ExperienceConfiguration.persistedGlassesSource() {
            do {
                try WearablesBootstrap.configure(using: source)
            } catch {
                Logger.wearables.error("Unable to configure Meta Wearables: \(error.localizedDescription)")
            }
        }
    }
}
