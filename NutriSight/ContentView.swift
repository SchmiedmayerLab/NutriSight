//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ContentView: View {
    @Environment(WearablesCoordinator.self) private var wearables
    @State private var configuration = ExperienceConfiguration()

    var body: some View {
        Group {
            if LaunchConfiguration.isTesting && !LaunchConfiguration.isUITesting {
                Color.clear
            } else if configuration.completedOnboarding {
                CaptureExperienceView(configuration: configuration, wearables: wearables)
            } else {
                SetupFlowView(configuration: configuration)
            }
        }
        .tint(.accentColor)
    }
}
