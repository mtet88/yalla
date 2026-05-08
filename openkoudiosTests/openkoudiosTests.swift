import Foundation
import Testing
@testable import openkoudios

struct openkoudiosTests {

    @Test func classifiesFoodIdeas() async throws {
        let result = IdeaClassifier.classify("Brunch en una cafeteria nueva el domingo")

        #expect(result.category == .food)
        #expect(result.idealConditions.contains(.day))
        #expect(result.idealConditions.contains(.weekend))
    }

    @Test func classifiesAccentInsensitiveIdeas() async throws {
        let result = IdeaClassifier.classify("Exposición gratis en el museo")

        #expect(result.category == .places)
        #expect(result.idealConditions.contains(.cheap))
    }

    @Test func normalizeOptionalLinkTrimsAndAddsScheme() async throws {
        #expect(normalizeOptionalLink("  example.com/plan ") == "https://example.com/plan")
        #expect(normalizeOptionalLink("http://example.com") == "http://example.com")
        #expect(normalizeOptionalLink("https://example.com") == "https://example.com")
        #expect(normalizeOptionalLink("   ") == nil)
        #expect(normalizeOptionalLink(nil) == nil)
    }

    @Test func scoringExcludesDoneAndDiscardedIdeas() async throws {
        let pending = makeIdea(id: "pending", status: .pending)
        let done = makeIdea(id: "done", status: .done)
        let discarded = makeIdea(id: "discarded", status: .discarded)

        let suggestions = IdeaScoring.suggestions(from: [pending, done, discarded])

        #expect(suggestions.map(\.idea.id) == ["pending"])
    }

    @Test func repeatableIdeasWaitFifteenDaysBeforeSuggestion() async throws {
        let recent = makeIdea(
            id: "recent",
            status: .repeatable,
            completedAt: daysAgo(3),
            lastRepeatedAt: daysAgo(3)
        )
        let old = makeIdea(
            id: "old",
            status: .repeatable,
            completedAt: daysAgo(20),
            lastRepeatedAt: daysAgo(16)
        )

        let suggestions = IdeaScoring.suggestions(from: [recent, old])

        #expect(suggestions.map(\.idea.id) == ["old"])
        #expect(suggestions.first?.reasons.contains("Es repetible y ya puede volver a sugerirse.") == true)
    }

    @Test func suggestionsReturnAtMostFiveIdeas() async throws {
        let ideas = (0..<8).map { index in
            makeIdea(id: "idea-\(index)", createdAt: daysAgo(index))
        }

        let suggestions = IdeaScoring.suggestions(from: ideas)

        #expect(suggestions.count == 5)
    }

    @Test func specificDateOnlyAppliesToSelectedDate() async throws {
        let targetDate = daysFromNow(5)
        let matching = makeIdea(id: "matching", dateType: .single, dateStart: targetDate)
        let other = makeIdea(id: "other", dateType: .single, dateStart: daysFromNow(6))
        let context = SuggestionContext(moment: .date, targetDate: targetDate)

        let suggestions = IdeaScoring.suggestions(from: [matching, other], context: context)

        #expect(suggestions.map(\.idea.id) == ["matching"])
        #expect(suggestions.first?.reasons.first?.contains("Cae en este momento") == true)
    }

    @Test func expirationDiscardsPastSingleDateWithoutDeleting() async throws {
        let now = Date()
        let expired = makeIdea(id: "expired", dateType: .single, dateStart: daysAgo(3))
        let current = makeIdea(id: "current", dateType: .single, dateStart: now)

        let result = IdeaExpiration.expirePastIdeas([expired, current], now: now)

        #expect(result.changed)
        #expect(result.ideas.count == 2)
        #expect(result.ideas.first { $0.id == "expired" }?.status == .discarded)
        #expect(result.ideas.first { $0.id == "expired" }?.discardedReason == .expired)
        #expect(result.ideas.first { $0.id == "current" }?.status == .pending)
    }

    @Test func expirationLeavesDoneRepeatableAndDiscardedIdeasUntouched() async throws {
        let done = makeIdea(id: "done", status: .done, dateType: .single, dateStart: daysAgo(10))
        let repeatable = makeIdea(id: "repeatable", status: .repeatable, dateType: .single, dateStart: daysAgo(10))
        let discarded = makeIdea(id: "discarded", status: .discarded, discardedReason: .manual, dateType: .single, dateStart: daysAgo(10))

        let result = IdeaExpiration.expirePastIdeas([done, repeatable, discarded])

        #expect(!result.changed)
        #expect(result.ideas.map(\.status) == [.done, .repeatable, .discarded])
        #expect(result.ideas.first { $0.id == "discarded" }?.discardedReason == .manual)
    }

    @Test func ideaStorePersistsAndReloadsLocalIdeas() async throws {
        let defaults = makeIsolatedDefaults()
        defaults.removeObject(forKey: "ideas:v1")

        let store = IdeaStore(defaults: defaults)
        let saved = store.addIdea(rawText: "  Picnic en el parque cuando este soleado  ", link: "openkoud.com")
        let reloaded = IdeaStore(defaults: defaults)

        #expect(saved.rawText == "Picnic en el parque cuando este soleado")
        #expect(saved.link == "https://openkoud.com")
        #expect(reloaded.ideas.count == 1)
        #expect(reloaded.ideas.first?.id == saved.id)
        #expect(reloaded.ideas.first?.category == .places)

        defaults.removeObject(forKey: "ideas:v1")
    }

    @Test func ideaStoreStatusUpdateMarksDiscardedAsManual() async throws {
        let defaults = makeIsolatedDefaults()
        defaults.removeObject(forKey: "ideas:v1")

        let store = IdeaStore(defaults: defaults)
        let idea = store.addIdea(rawText: "Concierto", link: nil)

        store.updateStatus(for: idea, status: .discarded)

        #expect(store.ideas.first?.status == .discarded)
        #expect(store.ideas.first?.discardedReason == .manual)

        defaults.removeObject(forKey: "ideas:v1")
    }

    private func makeIdea(
        id: String = "idea",
        status: IdeaStatus = .pending,
        discardedReason: DiscardedReason? = nil,
        dateType: IdeaDateType = .none,
        dateStart: Date? = nil,
        dateEnd: Date? = nil,
        category: IdeaCategory = .plans,
        idealConditions: [IdealCondition] = [],
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        lastRepeatedAt: Date? = nil
    ) -> Idea {
        Idea(
            id: id,
            rawText: id,
            title: id,
            link: nil,
            category: category,
            status: status,
            discardedReason: discardedReason,
            dateType: dateType,
            dateStart: dateStart,
            dateEnd: dateEnd,
            flexibleNote: nil,
            locationName: nil,
            latitude: nil,
            longitude: nil,
            address: nil,
            idealConditions: idealConditions,
            notes: nil,
            createdByUserId: nil,
            ownerUserId: nil,
            groupId: nil,
            createdAt: createdAt,
            updatedAt: createdAt,
            completedAt: completedAt,
            lastSuggestedAt: nil,
            lastRepeatedAt: lastRepeatedAt
        )
    }

    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "openkoudiosTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }

    private func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    private func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}
