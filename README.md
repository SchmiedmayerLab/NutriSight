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


## Testing

The shared `NutriSight.xctestplan` runs Swift Testing unit tests and five serialized end-to-end UI scenarios. The UI suite starts Meta's in-app Mock Device server, pairs and dons a simulated device, returns the bundled vegetarian Käsespätzle photo from the camera, injects a deterministic Muse Spark response, and uses an in-memory HealthKit writer. It therefore validates onboarding and API-key entry, localization, camera recovery, model-error recovery, and the complete meal pipeline without glasses, an API key, network access, or HealthKit authorization.

The [Cheese Spaetzle test photo](https://commons.wikimedia.org/wiki/File:Cheese-noodles-609776.jpg) by Hans Braxmeier was released under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/). The adjacent `.license` sidecars preserve the provenance and explicitly cover both the resized photo and its derived HEVC mock-camera feed.

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
