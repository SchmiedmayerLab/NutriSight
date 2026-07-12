//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import UIKit


private final class PreviewAssetsBundleToken {}


enum PreviewAssets {
    static var cheeseSpaetzle: UIImage? {
        guard let url = resourceBundles.lazy.compactMap({ bundle in
            bundle.url(forResource: "CheeseSpaetzle", withExtension: "jpg")
        }).first else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    static var cheeseSpaetzleData: Data? {
        cheeseSpaetzle?.jpegData(compressionQuality: 0.9)
    }

    private static var resourceBundles: [Bundle] {
        [Bundle.main, Bundle(for: PreviewAssetsBundleToken.self)] + Bundle.allBundles
    }
}
