//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct CameraActionsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: CaptureFeatureModel
    let captureAction: @MainActor () async throws -> Void
    let setupGlassesAction: () -> Void

    var body: some View {
        cameraAction
            .id(model.wearables.state)
            .padding(.bottom, captureBottomPadding)
            .animation(controlAnimation, value: captureBottomPadding)
            .controlSize(.large)
    }

    private var captureBottomPadding: CGFloat {
        guard model.wearables.state == .streaming else {
            return 0
        }
        return switch model.wearables.selectedSource {
        case .phoneCamera, .simulatedGlasses:
            88
        case .metaGlasses, nil:
            64
        }
    }

    private var controlAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.15) : .bouncy(duration: 0.45, extraBounce: 0.08)
    }

    @ViewBuilder private var cameraAction: some View {
        switch model.wearables.state {
        case .notRegistered:
            Button(action: setupGlassesAction) {
                cameraActionLabel(.pairMetaGlasses, systemImage: "eyeglasses")
            }
            .buttonStyle(.glassProminent)
            .accessibilityIdentifier("register-wearables")
        case .noDevice:
            Button(action: model.refreshCamera) {
                cameraActionLabel(.refreshGlasses, systemImage: "arrow.clockwise")
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.roundedRectangle(radius: 24))
            .accessibilityIdentifier("refresh-glasses")
        case .permissionRequired:
            Button(action: setupGlassesAction) {
                cameraActionLabel(.allowGlassesCamera, systemImage: "camera.badge.ellipsis")
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.roundedRectangle(radius: 24))
            .accessibilityIdentifier("allow-glasses-camera")
        case .ready, .connecting:
            EmptyView()
        case .streaming:
            AsyncButton(state: $model.viewState, action: captureAction) {
                Label(.takeMealPhoto, systemImage: "camera.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .frame(width: 72, height: 72)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .accessibilityLabel(.takeMealPhoto)
            .accessibilityIdentifier("take-photo")
        case .paused:
            AsyncButton(state: $model.viewState, action: model.connectCamera) {
                cameraActionLabel(.resumeGlassesCamera)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.roundedRectangle(radius: 24))
            .accessibilityIdentifier("resume-camera")
        }
    }

    private func cameraActionLabel(
        _ title: LocalizedStringResource,
        systemImage: String? = nil
    ) -> some View {
        Group {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }
}


#Preview("Camera Action · Pair", traits: .fixedLayout(width: 402, height: 140)) {
    @Previewable @State var model = CaptureFeatureModel(
        wearables: WearablesCoordinator(previewImage: nil, state: .notRegistered)
    )

    CameraActionsView(model: model, captureAction: {}, setupGlassesAction: {})
        .padding()
}


#Preview("Camera Action · Permission", traits: .fixedLayout(width: 402, height: 140)) {
    @Previewable @State var model = CaptureFeatureModel(
        wearables: WearablesCoordinator(previewImage: nil, state: .permissionRequired)
    )

    CameraActionsView(model: model, captureAction: {}, setupGlassesAction: {})
        .padding()
}


#Preview("Camera Action · Capture", traits: .fixedLayout(width: 402, height: 200)) {
    @Previewable @State var model = CaptureFeatureModel(
        wearables: WearablesCoordinator(
            previewImage: PreviewAssets.cheeseSpaetzle,
            state: .streaming,
            source: .metaGlasses
        )
    )

    CameraActionsView(model: model, captureAction: {}, setupGlassesAction: {})
        .padding()
}


#Preview("Camera Action · Simulated Glasses", traits: .fixedLayout(width: 402, height: 220)) {
    @Previewable @State var model = CaptureFeatureModel(
        wearables: WearablesCoordinator(
            previewImage: PreviewAssets.cheeseSpaetzle,
            state: .streaming,
            source: .simulatedGlasses
        )
    )

    CameraActionsView(model: model, captureAction: {}, setupGlassesAction: {})
        .padding()
}


#Preview("Camera Action · iPhone Camera", traits: .fixedLayout(width: 402, height: 220)) {
    @Previewable @State var model = CaptureFeatureModel(
        wearables: WearablesCoordinator(
            previewImage: PreviewAssets.cheeseSpaetzle,
            state: .streaming,
            source: .phoneCamera
        )
    )

    CameraActionsView(model: model, captureAction: {}, setupGlassesAction: {})
        .padding()
}


#Preview("Camera Action · Resume", traits: .fixedLayout(width: 402, height: 140)) {
    @Previewable @State var model = CaptureFeatureModel(
        wearables: WearablesCoordinator(previewImage: nil, state: .paused)
    )

    CameraActionsView(model: model, captureAction: {}, setupGlassesAction: {})
        .padding()
}
