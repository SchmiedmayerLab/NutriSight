//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum LaunchConfiguration {
    private(set) static var hasResetAPIKey = false

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--ui-testing")
    }

    static var isTesting: Bool {
        isUITesting || ProcessInfo.processInfo.environment["NUTRISIGHT_TESTING"] == "1"
    }

    static var usesMockLLM: Bool {
        ProcessInfo.processInfo.arguments.contains("--mock-llm")
    }

    static var simulatesMockLLMFailure: Bool {
        ProcessInfo.processInfo.arguments.contains("--mock-llm-failure")
    }

    static var simulatesCameraPause: Bool {
        ProcessInfo.processInfo.arguments.contains("--mock-camera-pause")
    }

    static var preparesSimulatedGlasses: Bool {
        ProcessInfo.processInfo.arguments.contains("--prepare-simulated-glasses")
    }

    static var usesMockHealthKit: Bool {
        ProcessInfo.processInfo.arguments.contains("--mock-healthkit")
    }

    static var resetsAPIKey: Bool {
        ProcessInfo.processInfo.arguments.contains("--reset-api-key")
    }

    static var allowsSampleAnalysis: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    static var allowsSimulatedGlasses: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    static func markAPIKeyReset() {
        hasResetAPIKey = true
    }
}
