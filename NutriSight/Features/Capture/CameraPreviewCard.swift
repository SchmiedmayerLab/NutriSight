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


#Preview("Camera Preview · Live", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var viewState: ViewState = .idle

    CameraPreviewCard(
        wearables: WearablesCoordinator(previewImage: PreviewAssets.cheeseSpaetzle),
        capturedImage: nil,
        viewState: $viewState,
        captureAction: {}
    )
    .background(.black)
}


#Preview("Camera Preview · Captured", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var viewState: ViewState = .idle

    CameraPreviewCard(
        wearables: WearablesCoordinator(previewImage: PreviewAssets.cheeseSpaetzle),
        capturedImage: PreviewAssets.cheeseSpaetzle,
        viewState: $viewState,
        captureAction: {}
    )
    .background(.black)
}


#Preview("Camera Preview · Connecting", traits: .fixedLayout(width: 402, height: 874)) {
    @Previewable @State var viewState: ViewState = .idle

    CameraPreviewCard(
        wearables: WearablesCoordinator(previewImage: nil, state: .connecting),
        capturedImage: nil,
        viewState: $viewState,
        captureAction: {}
    )
    .background(.black)
}
