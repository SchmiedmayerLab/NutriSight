//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CameraUnavailableView: View {
    let state: WearablesCameraState

    var body: some View {
        ContentUnavailableView {
            Label(state.title, systemImage: state.systemImage)
        } description: {
            Text(state.detail)
        }
        .foregroundStyle(.white)
    }
}


#Preview("Camera Unavailable", arguments: [WearablesCameraState.noDevice, .paused]) { state in
    CameraUnavailableView(state: state)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
