//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


final class NutriSightUITests: XCTestCase {
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
        let app = launchAppWithSimulatedGlasses()
        defer { app.terminate() }

        waitForCamera(in: app)
        try app.performAccessibilityAuditIgnoringContrast()

        let nutritionTitle = app.staticTexts["nutrition-title"]
        XCTAssertTrue(
            captureMeal(
                in: app,
                waitingFor: nutritionTitle,
                firstCaptureIdentifier: "camera-preview-capture"
            ),
            "The capture and sample-analysis flow did not reach the nutrition result."
        )
        XCTAssertTrue(app.buttons["close-nutrition-results"].waitForExistence(timeout: 5))
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
        let app = launchAppWithSimulatedGlasses(additionalArguments: ["--mock-llm-failure"])
        defer { app.terminate() }

        waitForCamera(in: app)
        XCTAssertTrue(
            captureMeal(in: app, waitingFor: app.buttons["retry-analysis"]),
            "The capture and sample-analysis flow did not reach the retry state."
        )
        app.buttons["retake-photo"].tap()
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testPausedGlassesCameraCanResume() throws {
        let app = launchAppWithSimulatedGlasses(additionalArguments: ["--mock-camera-pause"])
        defer { app.terminate() }

        let resumeButton = app.buttons["resume-camera"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 15))
        try app.performAccessibilityAuditIgnoringContrast()

        resumeButton.tap()
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 30))
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

        try app.performAccessibilityAuditAllowingFrameworkTimeout()
    }

    @MainActor
    private func launchAppWithSimulatedGlasses(
        additionalArguments: [String] = []
    ) -> XCUIApplication {
        launchApp(
            completedOnboarding: true,
            additionalArguments: ["--prepare-simulated-glasses"] + additionalArguments
        )
    }

    @MainActor
    private func launchApp(
        completedOnboarding: Bool,
        additionalArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--mock-llm",
            "--mock-healthkit",
            "-completedOnboarding",
            completedOnboarding ? "true" : "false"
        ] + additionalArguments
        if completedOnboarding {
            app.launchArguments += [
                "-glassesSource",
                "simulatedGlasses",
                "-analysisSource",
                "sampleAnalysis"
            ]
        } else {
            app.launchArguments += [
                "-glassesSource",
                "none",
                "-analysisSource",
                "none"
            ]
        }
        app.launch()
        return app
    }

    @MainActor
    private func waitForCamera(in app: XCUIApplication) {
        XCTAssertTrue(app.buttons["take-photo"].waitForExistence(timeout: 30))
    }

    @MainActor
    private func captureMeal(
        in app: XCUIApplication,
        waitingFor result: XCUIElement,
        firstCaptureIdentifier: String = "take-photo"
    ) -> Bool {
        let captureButton = app.buttons[firstCaptureIdentifier]
        guard waitUntilHittable(captureButton, timeout: 30) else {
            return false
        }
        captureButton.tap()

        let analysisProgress = app.descendants(matching: .any)["analysis-progress"]
        guard analysisProgress.waitForExistence(timeout: 20) else {
            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 2) {
                alert.buttons.firstMatch.tap()
            }
            return false
        }
        return result.waitForExistence(timeout: 45)
    }

    @MainActor
    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate { object, _ in
            (object as? XCUIElement)?.isHittable == true
        }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    private func waitForSaveConfirmation(in app: XCUIApplication) -> Bool {
        let confirmation = app.descendants(matching: .any)["health-save-confirmation"]
        let confirmationText = app.staticTexts["Saved for this preview"]
        for _ in 0..<5 {
            if confirmationText.waitForExistence(timeout: 1) {
                let alert = app.alerts.firstMatch
                if alert.exists {
                    alert.buttons.firstMatch.tap()
                }
                return confirmation.waitForExistence(timeout: 2)
            }
            if confirmation.waitForExistence(timeout: 1) {
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
    fileprivate func performAccessibilityAuditAllowingFrameworkTimeout() throws {
        do {
            try performAccessibilityAudit()
        } catch {
            try handleAccessibilityAuditFailure(error)
        }
    }

    fileprivate func performAccessibilityAuditIgnoringContrast() throws {
        do {
            try performAccessibilityAudit { issue in
                issue.auditType == .contrast
            }
        } catch {
            try handleAccessibilityAuditFailure(error)
        }
    }

    private func handleAccessibilityAuditFailure(_ error: any Error) throws {
        let error = error as NSError
        guard error.domain == "com.apple.xcode.xctest.accessibilityAudit", error.code == -56 else {
            throw error
        }
        throw XCTSkip("Xcode's accessibility audit did not complete before its framework timeout.")
    }
}
