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
        if showsOverlay {
            VStack(alignment: .center, spacing: 5) {
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
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .frame(maxWidth: 260, alignment: .center)
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    var showsOverlay: Bool {
        cameraState != .streaming
            || configuration.usesSimulatedGlasses
            || configuration.usesPhoneCamera
            || configuration.usesSampleAnalysis
    }
}


#Preview("Simulated Camera Status", traits: .fixedLayout(width: 402, height: 874)) {
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


#Preview("Live Camera · No Overlay", traits: .fixedLayout(width: 402, height: 874)) {
    ZStack(alignment: .top) {
        Image(uiImage: PreviewAssets.cheeseSpaetzle ?? UIImage())
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        CameraStatusOverlay(
            cameraState: .streaming,
            configuration: .preview(glassesSource: .metaGlasses, analysisSource: .metaModel)
        )
        .padding()
    }
}
