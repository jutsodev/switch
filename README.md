# Switch

Native iOS chat client for Claude Sonnet via an OpenAI-compatible endpoint, in a liquid-glass interface inspired by iOS 26.

- **Endpoint:** `https://api.ecomagent.in/v1`
- **Model:** `claude-sonnet-4-20250514`
- **Min iOS:** 16.0
- **Language:** Swift / SwiftUI

## Local development

```bash
brew install xcodegen
xcodegen generate
open Switch.xcodeproj
```

Hit ⌘R to run on a simulator or device.

## Continuous integration

`.github/workflows/ios.yml` runs on every push and pull request. It:

1. Installs XcodeGen via Homebrew on a macOS runner.
2. Regenerates `Switch.xcodeproj` from `project.yml`.
3. Builds the app for `iphoneos` with code signing disabled.
4. Packages the resulting `.app` as an unsigned `Switch.ipa`.
5. Uploads the `.ipa` as a workflow artifact.

Download the artifact from the GitHub Actions run page. Because the IPA is unsigned it cannot be installed on a stock device directly — sideload it with [AltStore](https://altstore.io/), [Sideloadly](https://sideloadly.io/), or re-sign with your own Apple Developer team in Xcode.

## Project layout

```
.
├── App/              Application entry point and lifecycle
├── Models/           Plain-data types (messages, conversations, models)
├── Services/         API client, persistence, haptics
├── ViewModels/       State containers binding views to services
├── Views/            SwiftUI screens
├── UI/               Reusable visual components (liquid glass, aurora, sparkle)
├── Resources/        Asset catalog
├── Info.plist
├── project.yml       XcodeGen project definition
└── .github/workflows/ios.yml
```

## Configuring the API key

A default key is compiled into `Services/APIClient.swift`. To override, open Settings inside the app and paste a key — it is stored in the iOS Keychain via `UserDefaults` (in this build a Keychain wrapper is intentionally omitted for simplicity).

If you ship the binary publicly, **rotate the key**: embedded secrets in an IPA can be extracted trivially.
