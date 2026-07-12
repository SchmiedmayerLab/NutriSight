//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The single presentation policy for both live glasses frames and the captured still shown in the viewfinder.
struct CameraViewfinderImage: View {
    let image: UIImage
    let accessibilityLabel: LocalizedStringResource

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .accessibilityLabel(accessibilityLabel)
    }
}
