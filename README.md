# Yalla

Native iOS SwiftUI port of `Yalla`: an app for saving ideas of plans and resurfacing them when it makes sense to do them.

The product rule is simple: **Guardar primero, enriquecer despues**. Saving an idea should only require free text plus an optional link. Everything else can be completed later.

## Product

`Vamos!` is the home screen. It suggests up to 5 valid ideas for a selected moment such as today, tomorrow, weekend, or a specific date.

V1 is local-first and personal:

```txt
Ideas persist in UserDefaults under ideas:v1.
No auth/backend is required for the core flow.
AI, weather, maps, and public share links are planned enrichments, not dependencies.
```

See `docs/product/` for the adapted product docs:

```txt
PRODUCT_PLAN.md
MVP_SPEC.md
TECHNICAL_PLAN.md
WIREFRAMES.md
```

## Project Structure

```txt
Yalla/
  Models/       Core Idea model and enums
  Services/     Classification, scoring, expiration
  Stores/       UserDefaults-backed IdeaStore
  Views/        SwiftUI screens and shared components

YallaTests/      Swift Testing unit tests
YallaUITests/    XCTest/XCUITest UI tests
```

The SwiftUI entrypoint is `Yalla/YallaApp.swift`, which loads `ContentView`, which loads `AppRootView`.

### Snapshot Testing
The application includes a visual testing system (Snapshot Tests) configured for **iPhone 17** (402x874pt).

- **Locales:** Each covered view is verified in Spanish (`es`) and English (`en`).
- **Modes:** Each locale is verified in both **Light Mode** and **Dark Mode**.
- **References:** Reference images are stored in `YallaTests/Snapshots/` with explicit names such as `IdeaDetailView_es_Light.png` and `IdeaDetailView_en_Dark.png`.
- **Regression:** If a view changes, the test will fail and attach a **Visual Diff** to the Xcode report highlighting the differences.
- **Updating:** Missing references are recorded and fail the test for review. To overwrite existing references, temporarily set `recordMode = true` in `SnapshotTests.swift`.

## Development

Open the project in Xcode:

```bash
open Yalla.xcodeproj
```

List schemes and targets:

```bash
xcodebuild -list -project Yalla.xcodeproj
```

Build from CLI:

```bash
xcodebuild -project Yalla.xcodeproj -scheme Yalla -destination 'platform=iOS Simulator,name=<installed simulator>' build
```

Run tests from CLI:

```bash
xcodebuild -project Yalla.xcodeproj -scheme Yalla -destination 'platform=iOS Simulator,name=<installed simulator>' test
```

Run only unit tests:

```bash
xcodebuild -project Yalla.xcodeproj -scheme Yalla -destination 'platform=iOS Simulator,name=<installed simulator>' -only-testing:YallaTests test
```

Run only UI tests:

```bash
xcodebuild -project Yalla.xcodeproj -scheme Yalla -destination 'platform=iOS Simulator,name=<installed simulator>' -only-testing:YallaUITests test
```

If `xcodebuild` reports that the active developer directory is CommandLineTools, select a full Xcode install first:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Current Notes

- This is an Xcode app project, not a Swift Package.
- The `.xcodeproj` uses file-system-synchronized root groups, so adding Swift files under the target folders should not require manually editing `project.pbxproj`.
- Info.plist is generated from build settings.
- Current local Xcode path is `/Applications/Xcode-26.4.1.app/Contents/Developer`.
- `xcodebuild -list`, CLI build, unit tests, and bilingual snapshot tests have passed in the current environment. If the Simulator intermittently fails with `NSMachErrorDomain Code=-308 "(ipc/mig) server died"`, treat it as a Simulator launch/runtime issue and rerun after the simulator recovers.
