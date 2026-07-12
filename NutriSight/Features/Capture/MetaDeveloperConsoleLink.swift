//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MetaDeveloperConsoleLink: View {
    var body: some View {
        if let consoleURL = MetaMusePlatformDefinition.platformDeveloperConsoleUrl {
            Link(destination: consoleURL) {
                Label(.openMetaDeveloperConsole, systemImage: "safari")
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .tint(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityIdentifier("meta-developer-console")
        }
    }
}


#Preview("Meta Developer Link") {
    MetaDeveloperConsoleLink()
        .padding()
}
