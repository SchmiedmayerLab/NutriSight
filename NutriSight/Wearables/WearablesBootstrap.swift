//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MWDATCore
import MWDATMockDevice
import OSLog


@MainActor
enum WearablesBootstrap {
    private static var configuredSource: GlassesSource?

    static func configure(using source: GlassesSource) throws {
        if source == .phoneCamera {
            configuredSource = source
            return
        }
        if let configuredSource {
            if configuredSource == source {
                return
            }
            guard configuredSource == .phoneCamera else {
                throw WearablesBootstrapError.sourceAlreadySelected
            }
            self.configuredSource = nil
        }

        if source == .simulatedGlasses {
            precondition(LaunchConfiguration.allowsSimulatedGlasses)
            MockDeviceKit.shared.enable(
                config: MockDeviceKitConfig(initiallyRegistered: true, initialPermissionsGranted: true)
            )
        }

        do {
            try Wearables.configure()
        } catch WearablesError.alreadyConfigured {
            // A preview or test host may have configured the process already.
        } catch {
            throw WearablesBootstrapError.sdk(error.localizedDescription)
        }
        if source == .simulatedGlasses
            && (!LaunchConfiguration.isUITesting || LaunchConfiguration.preparesSimulatedGlasses) {
            try prepareSimulatedGlasses()
        }
        configuredSource = source

        #if DEBUG
        if LaunchConfiguration.isUITesting,
           let portFilePath = ProcessInfo.processInfo.environment["MWDAT_TEST_SERVER_PORT_FILE"] {
            Task { @concurrent in
                do {
                    _ = try await MockDeviceKit.shared.startTestServer(portFilePath: portFilePath)
                } catch {
                    Logger.wearables.error("Unable to start the Mock Device test server: \(error.localizedDescription)")
                }
            }
        }
        #endif
    }

    private static func prepareSimulatedGlasses() throws {
        let glasses: any MockGlasses
        if let pairedGlasses = MockDeviceKit.shared.pairedDevices.first as? any MockGlasses {
            glasses = pairedGlasses
        } else {
            glasses = try MockDeviceKit.shared.pairGlasses(model: .rayBanMeta)
        }

        guard let feedURL = Bundle.main.url(forResource: "CheeseSpaetzleFeed", withExtension: "mov"),
              let photoURL = Bundle.main.url(forResource: "CheeseSpaetzle", withExtension: "jpg") else {
            throw WearablesBootstrapError.missingSimulatedMedia
        }
        glasses.services.camera.setCameraFeed(fileURL: feedURL)
        glasses.services.camera.setCapturedImage(fileURL: photoURL)
        glasses.powerOn()
        glasses.unfold()
        glasses.don()
    }
}


extension Logger {
    nonisolated static let wearables = Logger(subsystem: "edu.stanford.nutrisight", category: "Wearables")
}
