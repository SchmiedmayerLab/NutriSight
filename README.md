<!--

This source file is part of the NutriSight project

SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

# NutriSight

NutriSight is a Spezi-based prototype that captures a meal photo from Meta AI glasses, asks Meta's Muse Spark 1.1 model for a structured nutrition estimate, lets the user review the result, and can save supported dietary quantities to Apple Health.


## Prototype Setup

1. Configure the iOS application in the [Meta Wearables Developer Center](https://wearables.developer.meta.com/docs/develop/dat/build-overview/) and add the project-specific values required by the Device Access Toolkit.
2. Create a key in the [Meta developer console](https://dev.meta.ai/docs/getting-started/overview).
3. Run NutriSight and enter the key in the Muse Spark onboarding sheet. The prototype stores it in the iOS Keychain using SpeziKeychainStorage.
4. Pair supported glasses, start the glasses camera, and capture a meal photo. Review all generated estimates before saving them to Apple Health.

The API key is intentionally entered on-device for this prototype. A production deployment should exchange short-lived credentials through a trusted backend instead of distributing a long-lived model API key to the app.


## Wearables Architecture

`WearablesCoordinator` is an environment-accessible Spezi `Module` configured once by `NutriSightAppDelegate`. SwiftUI features access it with `@Environment(WearablesCoordinator.self)`. Its intent-oriented async API covers source selection, pairing and callback handling, camera authorization, camera start and stop, photo capture, refresh, updates, and unpairing. `status` provides an immutable snapshot, while `statusUpdates()` exposes buffered asynchronous updates.

The module enforces the SDK interaction order internally. It repairs missing configuration and listeners, rejects operations that require pairing or user authorization with typed errors, validates compatibility before session creation, reuses an active session, coalesces simultaneous camera starts, waits for the stream to become usable, and reconnects before capture when possible. A dedicated `DeviceSessionManager` owns `AutoDeviceSelector`, link and compatibility observation, lazy `DeviceSession` creation, startup races, reuse, and teardown. Meta SDK session objects never enter UI or feature code, leaving a focused boundary that can move into a Swift package later.


## Testing

The shared `NutriSight.xctestplan` runs Swift Testing unit tests and five serialized end-to-end UI scenarios. The UI suite starts Meta's in-app Mock Device server, pairs and dons a simulated device, returns the bundled vegetarian Käsespätzle photo from the camera, injects a deterministic Muse Spark response, and uses an in-memory HealthKit writer. It therefore validates onboarding and API-key entry, localization, camera recovery, model-error recovery, and the complete meal pipeline without glasses, an API key, network access, or HealthKit authorization.

When running the app normally in the iOS Simulator, sample analysis and simulated glasses still use the real HealthKit writer. This allows the complete authorization and nutrition-save flow to be tested against the simulator's Health database. The in-memory writer is selected only when the app is launched with `--mock-healthkit`, as the automated UI tests do.

The bundled Käsespätzle test media is an AI-generated first-person restaurant scene with a side salad and an unbranded glass of cola-orange soda. It includes a 3024×4032 captured-photo JPEG matching the glasses' portrait output and a corresponding 540×960, 24 fps HEVC feed following Meta's Mock Device Kit guidance. The adjacent `.license` sidecars preserve its provenance and CC0 licensing.

Run the same single-simulator lane used by CI:

```sh
fastlane test
```


## Contributing

Contributions to this project are welcome. Please read the [Contributor Covenant Code of Conduct](https://github.com/SchmiedmayerLab/.github/blob/main/CODE_OF_CONDUCT.md) first.


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.


## Our Research

For more information, visit the [Schmiedmayer Lab GitHub organization](https://github.com/SchmiedmayerLab).

![Stanford and Stanford Medicine logos](https://raw.githubusercontent.com/SchmiedmayerLab/.github/main/assets/stanford-footer-light.png#gh-light-mode-only)
![Stanford and Stanford Medicine logos](https://raw.githubusercontent.com/SchmiedmayerLab/.github/main/assets/stanford-footer-dark.png#gh-dark-mode-only)
