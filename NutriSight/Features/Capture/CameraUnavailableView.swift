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


#if DEBUG
#Preview("No Glasses") {
    CameraUnavailableView(state: .noDevice)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}

#Preview("Camera Paused") {
    CameraUnavailableView(state: .paused)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
#endif
