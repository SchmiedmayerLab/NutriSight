//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ContentView: View {
    @State private var configuration = ExperienceConfiguration()

    var body: some View {
        Group {
            if configuration.completedOnboarding {
                CaptureExperienceView(configuration: configuration)
            } else {
                SetupFlowView(configuration: configuration)
            }
        }
        .tint(.accentColor)
    }
}
