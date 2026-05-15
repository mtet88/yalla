import XCTest
import SwiftUI
@testable import openkoudios

@MainActor
final class SnapshotTests: XCTestCase {

    private var store: IdeaStore!

    override func setUp() {
        super.setUp()
        let defaults = UserDefaults(suiteName: "SnapshotTests")!
        defaults.removeObject(forKey: "ideas:v1")
        store = IdeaStore(defaults: defaults)
    }

    func testVamosViewEmptySnapshot() {
        let view = NavigationStack {
            VamosView(store: store, showSave: {})
        }
        assertSnapshot(for: view, name: "VamosView_Empty")
    }

    func testVamosViewWithSuggestionsSnapshot() {
        seedIdeas()
        let view = NavigationStack {
            VamosView(store: store, showSave: {})
        }
        assertSnapshot(for: view, name: "VamosView_WithSuggestions")
    }

    func testIdeasListViewSnapshot() {
        seedIdeas()
        let view = NavigationStack {
            IdeasListView(store: store, showSave: {})
        }
        assertSnapshot(for: view, name: "IdeasListView")
    }

    func testSaveIdeaViewSnapshot() {
        let view = NavigationStack {
            SaveIdeaView(store: store)
        }
        assertSnapshot(for: view, name: "SaveIdeaView")
    }

    func testAccountViewSnapshot() {
        let view = NavigationStack {
            AccountView()
        }
        assertSnapshot(for: view, name: "AccountView")
    }

    func testIdeaDetailViewSnapshot() {
        let idea = seedIdeas().first!
        let view = NavigationStack {
            IdeaDetailView(store: store, ideaID: idea.id)
        }
        assertSnapshot(for: view, name: "IdeaDetailView")
    }

    // MARK: - Helpers

    @discardableResult
    private func seedIdeas() -> [Idea] {
        var idea1 = store.addIdea(rawText: "Cena en el nuevo Japones", link: "https://example.com")
        var idea2 = store.addIdea(rawText: "Excursion a la montaña", link: nil)
        var idea3 = store.addIdea(rawText: "Concierto de Jazz", link: nil)

        let baseDate = fixedDate()
        idea1.createdAt = baseDate
        idea1.updatedAt = baseDate
        idea2.createdAt = baseDate
        idea2.updatedAt = baseDate
        idea3.createdAt = baseDate
        idea3.updatedAt = baseDate

        // Enrich idea 3
        idea3.category = .events
        idea3.dateType = .single
        idea3.dateStart = daysAfterFixedDate(1)
        store.updateIdea(idea1)
        store.updateIdea(idea2)
        store.updateIdea(idea3)

        return [idea1, idea2, idea3]
    }

    private func fixedDate() -> Date {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: 10))!
    }

    private func daysAfterFixedDate(_ days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: fixedDate())!
    }

    /// Set to `true` to overwrite existing snapshots with new ones.
    /// In a CI environment, this should always be `false`.
    private let recordMode = false
    private let snapshotLocales: [(id: String, locale: Locale)] = [
        ("es", Locale(identifier: "es")),
        ("en", Locale(identifier: "en")),
    ]

    private func assertSnapshot(for view: some View, name: String, file: StaticString = #file, line: UInt = #line) {
        for snapshotLocale in snapshotLocales {
            assertSnapshot(for: view, name: name, localeID: snapshotLocale.id, locale: snapshotLocale.locale, style: .light, file: file, line: line)
            assertSnapshot(for: view, name: name, localeID: snapshotLocale.id, locale: snapshotLocale.locale, style: .dark, file: file, line: line)
        }
    }

    private func assertSnapshot(for view: some View, name: String, localeID: String, locale: Locale, style: UIUserInterfaceStyle, file: StaticString, line: UInt) {
        let controller = UIHostingController(rootView: view.environment(\.locale, locale))
        controller.overrideUserInterfaceStyle = style
        let view = controller.view
        
        // Set a fixed size for snapshots (iPhone 17)
        let targetSize = CGSize(width: 402, height: 874)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = style == .dark ? .black : .systemBackground
        
        // Force layout
        view?.setNeedsLayout()
        view?.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            view?.drawHierarchy(in: view?.bounds ?? .zero, afterScreenUpdates: true)
        }
        
        guard let newData = image.pngData() else {
            XCTFail("Failed to generate PNG data for snapshot (\(style))", file: file, line: line)
            return
        }

        let styleSuffix = style == .dark ? "_Dark" : "_Light"
        let snapshotName = "\(name)_\(localeID)\(styleSuffix)"

        let testFileURL = URL(fileURLWithPath: "\(file)")
        let snapshotsDirectory = testFileURL
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
        let fileURL = snapshotsDirectory.appendingPathComponent("\(snapshotName).png")

        if recordMode {
            saveImage(newData, at: fileURL, directory: snapshotsDirectory)
            XCTFail("Record mode is ON. Snapshot saved at \(fileURL.path). Turn it off to run tests.", file: file, line: line)
            return
        }

        // Comparison logic
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let referenceData = try Data(contentsOf: fileURL)
                if newData != referenceData {
                    guard let referenceImage = UIImage(data: referenceData) else {
                        XCTFail("Failed to load reference image for comparison", file: file, line: line)
                        return
                    }
                    
                    // Generate visual diff
                    let diffImage = generateDiffImage(reference: referenceImage, current: image)
                    
                    // Attach all relevant images for inspection
                    attach(image: referenceImage, name: "\(snapshotName)_REFERENCE")
                    attach(image: image, name: "\(snapshotName)_CURRENT")
                    attach(image: diffImage, name: "\(snapshotName)_DIFF")
                    
                    XCTFail("Snapshot '\(snapshotName)' does not match reference. See DIFF attachment in the test report.", file: file, line: line)
                }
            } catch {
                XCTFail("Failed to load reference snapshot at \(fileURL.path): \(error)", file: file, line: line)
            }
        } else {
            // First time running, save as reference but fail to notify the user
            saveImage(newData, at: fileURL, directory: snapshotsDirectory)
            XCTFail("No reference snapshot found for '\(snapshotName)'. A new one has been recorded at \(fileURL.path). Please verify it and run the test again.", file: file, line: line)
        }
    }

    private func generateDiffImage(reference: UIImage, current: UIImage) -> UIImage {
        let size = reference.size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Draw reference
            reference.draw(in: CGRect(origin: .zero, size: size))
            
            // Draw current on top with Difference blend mode
            current.draw(in: CGRect(origin: .zero, size: size), blendMode: .difference, alpha: 1.0)
        }
    }

    private func attach(image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func saveImage(_ data: Data, at url: URL, directory: URL) {
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: url)
            print("Snapshot saved: \(url.path)")
        } catch {
            print("Failed to save snapshot: \(error)")
        }
    }
}
