//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MWDATMockDeviceTestClient
import XCTest


final class NutriSightUITests: XCTestCase {
    private struct MockDeviceContext {
        let client: MockDeviceTestClient
        let identifier: String
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testInitialAPIKeyOnboardingStoresAndRestoresPrototypeKey() throws {
        let app = launchApp(completedOnboarding: false, additionalArguments: ["--reset-api-key"])
        defer { app.terminate() }

        let welcomeButton = app.buttons["welcome-continue"]
        XCTAssertTrue(welcomeButton.waitForExistence(timeout: 10))
        welcomeButton.tap()

        let apiKeyField = app.secureTextFields["meta-api-key-field"]
        XCTAssertTrue(apiKeyField.waitForExistence(timeout: 10))
        let saveButton = app.buttons["save-api-key"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertFalse(saveButton.isEnabled)
        try app.performAccessibilityAuditIgnoringContrast()

        apiKeyField.tap()
        apiKeyField.typeText("test-meta-api-key-for-ui-tests")
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        let simulatedGlassesButton = app.buttons["Use Simulated Glasses"]
        XCTAssertTrue(simulatedGlassesButton.waitForExistence(timeout: 10))
        simulatedGlassesButton.tap()

        XCTAssertTrue(app.buttons["refresh-glasses"].waitForExistence(timeout: 10))
        app.buttons["experience-menu"].tap()
        let apiKeyMenuItem = app.buttons["meta-api-key"]
        XCTAssertTrue(apiKeyMenuItem.waitForExistence(timeout: 5))
        apiKeyMenuItem.tap()

        XCTAssertTrue(apiKeyField.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["save-api-key"].isEnabled, "The saved key should be restored from the Spezi keychain.")
        app.buttons["close-api-key"].tap()
        XCTAssertTrue(app.buttons["refresh-glasses"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testMealCaptureRetakeAnalysisHealthSaveAndStartAnotherMeal() throws {
        let (app, portFile) = launchAppWithPortFile()
        defer { app.terminate() }
        let device = try configureMealDevice(portFile: portFile)
        defer {
            device.client.unpairDevice(deviceId: device.identifier)
        }

        waitForCamera(in: app)
        try app.performAccessibilityAuditIgnoringContrast()

        let previewCapture = app.buttons["camera-preview-capture"]
        XCTAssertTrue(previewCapture.waitForExistence(timeout: 10))
        previewCapture.tap()
        XCTAssertTrue(app.descendants(matching: .any)["analysis-progress"].waitForExistence(timeout: 5))

        let nutritionTitle = app.staticTexts["nutrition-title"]
        XCTAssertTrue(nutritionTitle.waitForExistence(timeout: 10))
        app.swipeUp()

        let saveButton = app.buttons["save-health"]
        scrollToElement(saveButton, in: app)
        saveButton.tap()
        XCTAssertTrue(waitForSaveConfirmation(in: app))

        let analyzeAnotherButton = app.buttons["analyze-another"]
        scrollToElement(analyzeAnotherButton, in: app)
        analyzeAnotherButton.tap()
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSampleAnalysisFailureOffersRecovery() throws {
        let (app, portFile) = launchAppWithPortFile(additionalArguments: ["--mock-llm-failure"])
        defer { app.terminate() }
        let device = try configureMealDevice(portFile: portFile)
        defer {
            device.client.unpairDevice(deviceId: device.identifier)
        }

        waitForCamera(in: app)
        capturePhotoWithShutter(in: app)

        XCTAssertTrue(app.buttons["retry-analysis"].waitForExistence(timeout: 5))
        app.buttons["retake-photo"].tap()
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testPausedGlassesCameraCanResume() throws {
        let (app, portFile) = launchAppWithPortFile(additionalArguments: ["--mock-camera-pause"])
        defer { app.terminate() }
        let device = try configureMealDevice(portFile: portFile)
        defer {
            device.client.unpairDevice(deviceId: device.identifier)
        }

        let resumeButton = app.buttons["resume-camera"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 15))
        try app.performAccessibilityAuditIgnoringContrast()

        resumeButton.tap()
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 15))
    }

    @MainActor
    func testGermanNoDeviceLayoutAndAccessibility() throws {
        let app = launchApp(
            completedOnboarding: true,
            additionalArguments: ["-AppleLanguages", "(de)", "-AppleLocale", "de_DE"]
        )
        defer { app.terminate() }

        let refreshButton = app.buttons["refresh-glasses"]
        XCTAssertTrue(refreshButton.waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["camera-preview"].exists)
        refreshButton.tap()

        try app.performAccessibilityAudit()
    }

    @MainActor
    private func launchAppWithPortFile(
        additionalArguments: [String] = []
    ) -> (app: XCUIApplication, portFile: String) {
        let portFile = FileManager.default.temporaryDirectory
            .appending(path: "nutrisight-mock-device-\(UUID().uuidString).port")
            .path()
        let app = launchApp(
            completedOnboarding: true,
            additionalArguments: additionalArguments,
            portFile: portFile
        )
        return (app, portFile)
    }

    @MainActor
    private func launchApp(
        completedOnboarding: Bool,
        additionalArguments: [String] = [],
        portFile: String? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--mock-llm",
            "--mock-healthkit",
            "-completedOnboarding",
            completedOnboarding ? "true" : "false",
            "-glassesSource",
            "simulatedGlasses",
            "-analysisSource",
            "sampleAnalysis"
        ] + additionalArguments
        if let portFile {
            app.launchEnvironment["MWDAT_TEST_SERVER_PORT_FILE"] = portFile
        }
        app.launch()
        return app
    }

    @MainActor
    private func configureMealDevice(portFile: String) throws -> MockDeviceContext {
        let client = MockDeviceTestClient(portFilePath: portFile)
        XCTAssertTrue(client.waitForServer(timeout: 15), "The in-app mock-device server did not start.")
        let identifier = try XCTUnwrap(client.pairDevice())
        XCTAssertTrue(client.powerOn(deviceId: identifier))
        XCTAssertTrue(client.unfold(deviceId: identifier))
        XCTAssertTrue(client.don(deviceId: identifier))
        XCTAssertTrue(client.setCameraFeed(deviceId: identifier, resourceName: "CheeseSpaetzleFeed", ext: "mov"))
        XCTAssertTrue(client.setCapturedImage(deviceId: identifier, resourceName: "CheeseSpaetzle", ext: "jpg"))
        return MockDeviceContext(client: client, identifier: identifier)
    }

    @MainActor
    private func waitForCamera(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 15))
    }

    @MainActor
    private func capturePhotoWithShutter(in app: XCUIApplication) {
        app.buttons["take-photo"].tap()
    }

    @MainActor
    private func waitForSaveConfirmation(in app: XCUIApplication) -> Bool {
        let confirmation = app.descendants(matching: .any)["health-save-confirmation"]
        let confirmationText = app.staticTexts["Saved for this preview"]
        for _ in 0..<5 {
            if confirmation.waitForExistence(timeout: 1) || confirmationText.waitForExistence(timeout: 1) {
                return true
            }
            app.swipeUp()
        }
        return false
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<5 where !element.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }
}


extension XCUIApplication {
    fileprivate func performAccessibilityAuditIgnoringContrast() throws {
        try performAccessibilityAudit { issue in
            issue.auditType == .contrast
        }
    }
}
