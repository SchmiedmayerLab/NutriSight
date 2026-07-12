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
    @Bindable var model: CaptureFeatureModel
    let captureAction: @MainActor () async throws -> Void

    var body: some View {
        cameraAction
            .controlSize(.large)
    }

    @ViewBuilder private var cameraAction: some View {
        switch model.camera.state {
        case .notRegistered:
            AsyncButton(.registerWithMetaAi, state: $model.viewState, action: model.registerWearables)
                .buttonStyle(.glassProminent)
                .accessibilityIdentifier("register-wearables")
        case .noDevice:
            Button(action: model.refreshCamera) {
                cameraActionLabel(.refreshGlasses, systemImage: "arrow.clockwise")
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.roundedRectangle(radius: 24))
            .accessibilityIdentifier("refresh-glasses")
        case .ready, .connecting:
            Label {
                Text(.connectingToGlasses)
            } icon: {
                ProgressView()
            }
            .padding()
            .glassEffect(.regular, in: .capsule)
            .accessibilityIdentifier("camera-connecting")
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
