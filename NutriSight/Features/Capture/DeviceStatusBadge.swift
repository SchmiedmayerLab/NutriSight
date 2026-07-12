//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DeviceStatusBadge: View {
    let state: WearablesCameraState

    var body: some View {
        Label(state.title, systemImage: state.systemImage)
            .font(.subheadline)
            .bold()
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("device-status")
    }
}


#if DEBUG
#Preview("Device Status") {
    DeviceStatusBadge(state: .streaming)
        .padding()
}
#endif
