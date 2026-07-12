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
            }
            .buttonStyle(.bordered)
            .tint(.primary)
            .accessibilityIdentifier("meta-developer-console")
        }
    }
}


#if DEBUG
#Preview("Meta Developer Link") {
    MetaDeveloperConsoleLink()
        .padding()
}
#endif
