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
    let camera: WearablesCamera

    private(set) var workflowState: CaptureWorkflowState = .camera
    private(set) var capturedImageData: Data?
    private(set) var capturedImage: UIImage?
    private(set) var analysis: NutritionAnalysis?
    var viewState: ViewState = .idle

    init(camera: WearablesCamera = WearablesCamera()) {
        self.camera = camera
    }

    func start() {
        camera.start()
    }

    func registerWearables() async throws {
        try await camera.register()
    }

    func connectCamera() async throws {
        try await camera.connect()
    }

    func refreshCamera() {
        camera.refresh()
    }

    func connectWhenReady() async {
        guard camera.state == .ready else {
            return
        }
        do {
            try await camera.connect()
        } catch let error as any LocalizedError {
            viewState = .error(error)
        } catch {
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }

    func handleWearablesURL(_ url: URL) async {
        do {
            try await camera.handle(url)
        } catch let error as any LocalizedError {
            viewState = .error(error)
        } catch {
            viewState = .error(WearablesCameraError.sdk(error.localizedDescription))
        }
    }

    func capture() async throws {
        try receiveCapturedPhoto(await camera.capturePhoto())
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
