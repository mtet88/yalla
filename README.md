# openkoudios

Native iOS SwiftUI port of `openkoud`: an app for saving ideas of plans and resurfacing them when it makes sense to do them.

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
openkoudios/
  Models/       Core Idea model and enums
  Services/     Classification, scoring, expiration
  Stores/       UserDefaults-backed IdeaStore
  Views/        SwiftUI screens and shared components

openkoudiosTests/      Swift Testing unit tests
openkoudiosUITests/    XCTest/XCUITest UI tests
```

The SwiftUI entrypoint is `openkoudios/openkoudiosApp.swift`, which loads `ContentView`, which loads `AppRootView`.

## Development

Open the project in Xcode:

```bash
open openkoudios.xcodeproj
```

List schemes and targets:

```bash
xcodebuild -list -project openkoudios.xcodeproj
```

Build from CLI:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' build
```

Run tests from CLI:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' test
```

Run only unit tests:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' -only-testing:openkoudiosTests test
```

Run only UI tests:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' -only-testing:openkoudiosUITests test
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
- `xcodebuild -list` works. Full and unit-only test commands currently fail during Simulator app launch with `NSMachErrorDomain Code=-308 "(ipc/mig) server died"`, after building far enough to attempt launch.
