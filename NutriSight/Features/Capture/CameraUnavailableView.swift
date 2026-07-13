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


#Preview("Camera Unavailable · Not Paired", traits: .fixedLayout(width: 402, height: 874)) {
    CameraUnavailableView(state: .notRegistered)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}


#Preview("Camera Unavailable · No Device", traits: .fixedLayout(width: 402, height: 874)) {
    CameraUnavailableView(state: .noDevice)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}


#Preview("Camera Unavailable · Permission", traits: .fixedLayout(width: 402, height: 874)) {
    CameraUnavailableView(state: .permissionRequired)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}


#Preview("Camera Unavailable · Paused", traits: .fixedLayout(width: 402, height: 874)) {
    CameraUnavailableView(state: .paused)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
