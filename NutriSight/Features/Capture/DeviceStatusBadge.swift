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
        if state != .streaming {
            Label(state.title, systemImage: state.systemImage)
                .font(.footnote)
                .bold()
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("device-status")
        }
    }
}


#Preview("Device Statuses", traits: .sizeThatFitsLayout) {
    Grid(alignment: .leading, verticalSpacing: 12) {
        ForEach(WearablesCameraState.allCases, id: \.self) { state in
            GridRow {
                Text(String(describing: state))
                    .foregroundStyle(.secondary)
                DeviceStatusBadge(state: state)
            }
        }
    }
    .padding()
}
