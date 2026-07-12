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
    let camera: WearablesCamera
    let capturedImage: UIImage?
    @Binding var viewState: ViewState
    let captureAction: @MainActor () async throws -> Void

    private var displayedImage: UIImage? {
        capturedImage ?? camera.previewImage
    }

    var body: some View {
        Group {
            if let displayedImage {
                if camera.state == .streaming && capturedImage == nil {
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
                CameraUnavailableView(state: camera.state)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("camera-preview")
            }
        }
    }

    private func previewImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(.rect)
            .accessibilityLabel(capturedImage == nil ? .liveCameraPreview : .capturedMealPhoto)
            .accessibilityIdentifier(capturedImage == nil ? "live-camera-image" : "camera-preview")
    }
}
