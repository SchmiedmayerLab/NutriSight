//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Serializes all AVFoundation capture-session work away from the main actor.
@globalActor
actor PhoneCameraSessionActor {
    static let shared = PhoneCameraSessionActor()

    nonisolated let dispatchQueue: DispatchSerialQueue

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        // The actor owns this immutable serial queue for its entire lifetime.
        unsafe dispatchQueue.asUnownedSerialExecutor()
    }

    private init() {
        let queue = DispatchQueue(
            label: "edu.stanford.nutrisight.phone-camera.session",
            qos: .userInitiated
        )
        guard let serialQueue = queue as? DispatchSerialQueue else {
            preconditionFailure("Phone camera session queue must be serial.")
        }
        self.dispatchQueue = serialQueue
    }
}
