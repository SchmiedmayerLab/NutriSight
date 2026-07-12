//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CameraStatusOverlay: View {
    let cameraState: WearablesCameraState
    let configuration: ExperienceConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DeviceStatusBadge(state: cameraState)
            if configuration.usesSimulatedGlasses {
                ExperienceSourceBadge(title: .simulatedGlasses, systemImage: "eyeglasses")
            }
            if configuration.usesSampleAnalysis {
                ExperienceSourceBadge(title: .sampleAnalysis, systemImage: "wand.and.stars")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .fixedSize(horizontal: false, vertical: true)
    }
}


#if DEBUG
#Preview("Simulated Camera Status") {
    ZStack(alignment: .topLeading) {
        Image(uiImage: PreviewAssets.cheeseSpaetzle ?? UIImage())
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        CameraStatusOverlay(
            cameraState: .streaming,
            configuration: .preview(glassesSource: .simulatedGlasses, analysisSource: .sampleAnalysis)
        )
        .padding()
    }
}
#endif
