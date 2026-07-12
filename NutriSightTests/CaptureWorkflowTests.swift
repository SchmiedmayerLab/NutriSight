//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import NutriSight
import Testing
import UIKit


@MainActor
@Suite("Capture workflow")
struct CaptureWorkflowTests {
    @Test("Completes capture, analysis, save, and retake")
    func completesWorkflow() async throws {
        let model = CaptureFeatureModel()
        let imageData = try #require(testImageData())

        try model.receiveCapturedPhoto(imageData)
        #expect(model.workflowState == .captured)
        #expect(model.capturedImage != nil)

        try await model.analyze(using: MockNutritionAnalyzer())
        #expect(model.workflowState == .result)
        #expect(model.analysis == .cheeseSpaetzleFixture)

        try await model.save(using: MockNutritionHealthStore())
        #expect(model.workflowState == .saved)

        model.retake()
        #expect(model.workflowState == .camera)
        #expect(model.capturedImageData == nil)
        #expect(model.capturedImage == nil)
        #expect(model.analysis == nil)
    }

    @Test("Rejects invalid captured image data")
    func rejectsInvalidImage() {
        let model = CaptureFeatureModel()

        #expect(throws: NutritionAnalysisError.invalidImage) {
            try model.receiveCapturedPhoto(Data([0x00]))
        }
        #expect(model.workflowState == .camera)
        #expect(model.capturedImageData == nil)
    }

    @Test("Restores captured state after analysis failure")
    func restoresCapturedStateAfterAnalysisFailure() async throws {
        let model = CaptureFeatureModel()
        let imageData = try #require(testImageData())
        try model.receiveCapturedPhoto(imageData)

        await #expect(throws: NutritionAnalysisError.invalidResponse) {
            try await model.analyze(using: MockNutritionAnalyzer(shouldFail: true))
        }
        #expect(model.workflowState == .captured)
        #expect(model.analysis == nil)
        #expect(model.capturedImageData == imageData)
    }

    @Test("Rejects analysis and save without required state")
    func rejectsMissingState() async {
        let model = CaptureFeatureModel()

        await #expect(throws: NutritionAnalysisError.invalidImage) {
            try await model.analyze(using: MockNutritionAnalyzer())
        }
        await #expect(throws: NutritionAnalysisError.invalidResponse) {
            try await model.save(using: MockNutritionHealthStore())
        }
    }

    private func testImageData() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
        return renderer.image { context in
            UIColor.systemOrange.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 2, height: 2)))
        }
        .jpegData(compressionQuality: 1)
    }
}
