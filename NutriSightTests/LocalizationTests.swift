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


@MainActor
@Suite("Localization")
struct LocalizationTests {
    @Test("Every nutrient name resolves in English and German", arguments: ["en", "de"])
    func nutrientNamesResolve(language: String) {
        let locale = Locale(identifier: language)
        let names = NutrientKind.allCases.map { kind in
            localized(kind.displayName, locale: locale)
        }

        #expect(names.allSatisfy { !$0.isEmpty && !$0.hasPrefix("NUTRIENT_") })
        #expect(Set(names).count == NutrientKind.allCases.count)
    }

    @Test("Every camera state resolves a title and detail", arguments: ["en", "de"])
    func cameraStatesResolve(language: String) {
        let locale = Locale(identifier: language)
        let states: [WearablesCameraState] = [.notRegistered, .noDevice, .ready, .connecting, .streaming, .paused]

        for state in states {
            let title = localized(state.title, locale: locale)
            let detail = localized(state.detail, locale: locale)
            #expect(!title.isEmpty)
            #expect(!detail.isEmpty)
            #expect(!title.hasPrefix("CAMERA_"))
            #expect(!detail.hasPrefix("CAMERA_"))
        }
    }

    @Test("Nutrient values use the locale's decimal separator")
    func nutrientValuesAreLocalized() {
        let english = NutrientKind.protein.formattedAmount(12.5, locale: Locale(identifier: "en_US"))
        let german = NutrientKind.protein.formattedAmount(12.5, locale: Locale(identifier: "de_DE"))

        #expect(english.contains("12.5"))
        #expect(german.contains("12,5"))
    }

    private func localized(_ resource: LocalizedStringResource, locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
