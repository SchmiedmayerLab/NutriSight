//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Observation
import SpeziViews
import SwiftUI


@MainActor
@Observable
final class CaptureFeatureModel {
    let wearables: WearablesCoordinator

    private(set) var workflowState: CaptureWorkflowState = .camera
    private(set) var capturedImageData: Data?
    private(set) var capturedImage: UIImage?
    private(set) var analysis: NutritionAnalysis?
    private var isConnectingCamera = false
    var viewState: ViewState = .idle

    init(wearables: WearablesCoordinator = WearablesCoordinator()) {
        self.wearables = wearables
    }

    func start(source: GlassesSource?) async {
        do {
            try await wearables.selectSource(source)
        } catch let error as any LocalizedError {
            viewState = .error(error)
        } catch {
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }

    func connectCamera() async throws {
        guard !isConnectingCamera else {
            return
        }
        isConnectingCamera = true
        defer {
            isConnectingCamera = false
        }
        try await wearables.startCamera()
    }

    func refreshCamera() {
        wearables.refreshDevices()
    }

    func connectWhenReady() async {
        guard wearables.state == .ready, !isConnectingCamera else {
            return
        }
        isConnectingCamera = true
        defer {
            isConnectingCamera = false
        }
        do {
            try await wearables.startCamera()
        } catch WearablesCameraError.permissionRequired {
            return
        } catch let error as any LocalizedError {
            viewState = .error(error)
        } catch {
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }

    func handleWearablesURL(_ url: URL) async {
        do {
            try await wearables.selectSource(.metaGlasses)
            try await wearables.handleRegistrationCallback(url)
        } catch let error as any LocalizedError {
            viewState = .error(error)
        } catch {
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }

    func capture() async throws {
        try receiveCapturedPhoto(await wearables.capturePhoto())
    }

    func beginCapture() {
        workflowState = .capturing
    }

    func cancelCapture() {
        workflowState = .camera
    }

    func receiveCapturedPhoto(_ data: Data) throws {
        guard let image = UIImage(data: data) else {
            throw NutritionAnalysisError.invalidImage
        }
        capturedImageData = data
        capturedImage = image
        analysis = nil
        workflowState = .captured
    }

    func analyze(using analyzer: any NutritionAnalyzing) async throws {
        guard let capturedImageData else {
            throw NutritionAnalysisError.invalidImage
        }
        workflowState = .analyzing
        do {
            analysis = try await analyzer.analyze(imageData: capturedImageData)
            workflowState = .result
        } catch {
            workflowState = .captured
            throw error
        }
    }

    func save(using healthStore: any NutritionHealthStoring) async throws {
        guard let analysis else {
            throw NutritionAnalysisError.invalidResponse
        }
        try await healthStore.save(analysis)
        workflowState = .saved
    }

    func retake() {
        capturedImageData = nil
        capturedImage = nil
        analysis = nil
        workflowState = .camera
        viewState = .idle
    }
}


extension CaptureFeatureModel {
    // periphery:ignore - Creates states used exclusively by `#Preview` declarations, which Periphery cannot trace.
    convenience init(
        previewWorkflowState workflowState: CaptureWorkflowState,
        analysis: NutritionAnalysis? = nil,
        capturedImageData: Data? = PreviewAssets.cheeseSpaetzleData
    ) {
        self.init()
        if let capturedImageData {
            try? receiveCapturedPhoto(capturedImageData)
        }
        self.analysis = analysis
        self.workflowState = workflowState
    }
}
