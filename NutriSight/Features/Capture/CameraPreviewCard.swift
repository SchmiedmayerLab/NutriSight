//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct CameraPreviewCard: View {
    let wearables: WearablesCoordinator
    let capturedImage: UIImage?
    @Binding var viewState: ViewState
    let captureAction: @MainActor () async throws -> Void

    private var displayedImage: UIImage? {
        capturedImage ?? wearables.previewImage
    }

    var body: some View {
        Group {
            if let displayedImage {
                if wearables.canCapture && capturedImage == nil {
                    AsyncButton(state: $viewState, action: captureAction) {
                        previewImage(displayedImage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(.tapCameraToCapture)
                    .accessibilityIdentifier("camera-preview-capture")
                } else {
                    previewImage(displayedImage)
                }
            } else {
                CameraUnavailableView(state: wearables.state)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("camera-preview")
            }
        }
    }

    private func previewImage(_ image: UIImage) -> some View {
        CameraViewfinderImage(
            image: image,
            accessibilityLabel: capturedImage == nil ? .liveCameraPreview : .capturedMealPhoto
        )
            .contentShape(.rect)
            .accessibilityIdentifier(capturedImage == nil ? "live-camera-image" : "camera-preview")
    }
}


#Preview("Camera Preview Crop Alignment") {
    @Previewable @State var viewState: ViewState = .idle
    let previewImage = PreviewAssets.cheeseSpaetzle

    VStack(spacing: 0) {
        CameraPreviewCard(
            wearables: WearablesCoordinator(previewImage: previewImage),
            capturedImage: nil,
            viewState: $viewState,
            captureAction: {}
        )
        .overlay(alignment: .topLeading) {
            previewStateLabel("Live")
        }

        CameraPreviewCard(
            wearables: WearablesCoordinator(previewImage: previewImage),
            capturedImage: previewImage,
            viewState: $viewState,
            captureAction: {}
        )
        .overlay(alignment: .topLeading) {
            previewStateLabel("Captured")
        }
    }
    .background(.black)
}


private func previewStateLabel(_ title: String) -> some View {
    Text(title)
        .font(.caption.bold())
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .glassEffect(.regular, in: .capsule)
        .padding()
}
