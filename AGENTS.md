# AGENTS.md

## Project Shape
- This is a single native Xcode iOS app project, not a Swift Package, JS repo, or Next.js app. Use `openkoudios.xcodeproj`; there is no `Package.swift`, package manager lockfile, CI config, formatter, or lint config in the repo.
- Product docs are source-of-truth context and live in `docs/product/`: `PRODUCT_PLAN.md`, `MVP_SPEC.md`, `TECHNICAL_PLAN.md`, and `WIREFRAMES.md`.
- Main app code is in `openkoudios/`; the SwiftUI entrypoint is `openkoudios/openkoudiosApp.swift`, which launches `ContentView`, which loads `AppRootView`.
- The app is a native SwiftUI port of the `openkoud` product. Core domain code is split into `Models/`, `Services/`, `Stores/`, and `Views/` under `openkoudios/`.
- Unit tests live in `openkoudiosTests/` and use Swift Testing (`import Testing`, `@Test`, `#expect`). UI tests live in `openkoudiosUITests/` and use XCTest/XCUITest.

## Xcode Project Gotchas
- The `.xcodeproj` uses Xcode file-system-synchronized root groups for `openkoudios/`, `openkoudiosTests/`, and `openkoudiosUITests/`; adding Swift files under those folders should not require manually editing `project.pbxproj`.
- Info.plist is generated from build settings (`GENERATE_INFOPLIST_FILE = YES`); do not look for or add a physical plist unless the project is intentionally changed.
- App target settings include iPhone/iPad support (`TARGETED_DEVICE_FAMILY = 1,2`), bundle id `matom.openkoudios`, deployment target `IPHONEOS_DEPLOYMENT_TARGET = 26.4`, Swift version `5.0`, approachable concurrency, and default actor isolation `MainActor`.

## Product Direction
- Product copy is Spanish and the home tab is `Vamos!`, not the ideas list.
- Core product rule: "Guardar primero, enriquecer despues"; creating an idea should require only free text plus optional link.
- V1 is local-first and personal, but the model should stay ready for future groups via nullable `groupId`.
- The experience should feel like a social plans app even while V1 works locally for one person.
- Do not make AI, auth, backend, GPS, map, or weather mandatory for the core local flow.

## Data And Behavior
- Guest ideas persist locally in `UserDefaults` under key `ideas:v1`, mirroring the source web app's localStorage schema.
- Ideas marked `done` or `discarded` must not be suggested.
- `repeatable` ideas can be suggested only after 15 days.
- Suggestions should be deterministic and explainable, returning up to 5 ideas with clear reasons.
- Creating an idea may classify category/conditions with local rules, but should never block because classification, date parsing, location, weather, or link enrichment failed.

## Current App Structure
- `Models/Idea.swift` defines the core idea model, categories, states, date types, ideal conditions, suggestion context, and scored ideas.
- `Stores/IdeaStore.swift` owns local persistence and CRUD operations.
- `Services/IdeaClassifier.swift`, `IdeaScoring.swift`, and `IdeaExpiration.swift` contain local product logic.
- `Views/AppRootView.swift` defines the main tab structure and global save action.
- `Views/VamosView.swift`, `IdeasListView.swift`, `SaveIdeaView.swift`, `IdeaDetailView.swift`, and `AccountView.swift` map to the main product surfaces.
- Shared SwiftUI components live in `Views/Components.swift`.

## Planned Integrations
- CoreLocation is the planned way to request user location when weather/proximity is needed. Keep the app usable if permission is denied.
- Open-Meteo is the planned weather API. Weather should enrich scoring, not be required to save or browse ideas.
- MapKit is the preferred native map/pin selection path for iOS, replacing the web app's Leaflet plan.
- Supabase Auth/Postgres comes after the local core works; never delete local ideas before confirmed remote migration.
- Public share links are planned; current native sharing may use `ShareLink` / iOS share sheet with text.

## UI And Copy
- Build for iPhone first and keep iPad functional; preserve native SwiftUI navigation conventions unless product docs explicitly require custom behavior.
- Main tabs are `Vamos!`, `Ideas`, and `Cuenta`. `Guardar idea` is a focused flow opened from a global `+` action.
- Hide or avoid global navigation chrome during focused save/detail flows when it creates accidental exits or distraction.
- UI copy is Spanish. Existing source may include non-ASCII Spanish such as `Mañana`; otherwise prefer ASCII if editing nearby ASCII-only text.

## Commands
- Open in Xcode: `open openkoudios.xcodeproj`.
- List schemes/targets: `xcodebuild -list -project openkoudios.xcodeproj`.
- Build from CLI: `xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' build`.
- Run all tests from CLI: `xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' test`.
- If `xcodebuild` reports the active developer directory is CommandLineTools, select a full Xcode install first, e.g. `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.

## Current Verification State
- `xcodebuild` commands could not be verified in this environment because the active developer directory is `/Library/Developer/CommandLineTools`, which cannot build Xcode projects.
