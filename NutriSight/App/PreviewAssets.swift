//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if DEBUG
import UIKit


enum PreviewAssets {
    static var cheeseSpaetzle: UIImage? {
        guard let url = Bundle.main.url(forResource: "CheeseSpaetzle", withExtension: "jpg") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path())
    }
}
#endif
