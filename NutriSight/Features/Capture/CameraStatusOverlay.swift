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
        VStack(alignment: .center, spacing: 8) {
            DeviceStatusBadge(state: cameraState)
            if configuration.usesSimulatedGlasses {
                ExperienceSourceBadge(title: .simulatedGlasses, systemImage: "eyeglasses")
            }
            if configuration.usesPhoneCamera {
                ExperienceSourceBadge(title: "iPhone Camera", systemImage: "camera")
            }
            if configuration.usesSampleAnalysis {
                ExperienceSourceBadge(title: .sampleAnalysis, systemImage: "wand.and.stars")
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: 320, alignment: .center)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .fixedSize(horizontal: false, vertical: true)
    }
}


#Preview("Simulated Camera Status") {
    ZStack(alignment: .top) {
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
