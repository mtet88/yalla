import Foundation
import Observation

@Observable
final class IdeaStore {
    private let storageKey = "ideas:v1"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var ideas: [Idea] = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            ideas = []
            return
        }

        do {
            let decoded = try decoder.decode([Idea].self, from: data)
            let expired = IdeaExpiration.expirePastIdeas(decoded)
            ideas = expired.ideas

            if expired.changed {
                persist()
            }
        } catch {
            ideas = []
        }
    }

    @discardableResult
    func addIdea(rawText: String, link: String?) -> Idea {
        let idea = createIdea(rawText: rawText, link: link)
        ideas.insert(idea, at: 0)
        persist()
        return idea
    }

    func updateIdea(_ idea: Idea) {
        guard let index = ideas.firstIndex(where: { $0.id == idea.id }) else { return }
        var updated = idea
        updated.updatedAt = Date()
        ideas[index] = updated
        persist()
    }

    func updateStatus(for idea: Idea, status: IdeaStatus) {
        guard let index = ideas.firstIndex(where: { $0.id == idea.id }) else { return }
        ideas[index].applyStatus(status)
        ideas[index].updatedAt = Date()
        persist()
    }

    func deleteIdea(_ idea: Idea) {
        ideas.removeAll { $0.id == idea.id }
        persist()
    }

    func idea(with id: Idea.ID) -> Idea? {
        ideas.first { $0.id == id }
    }

    private func createIdea(rawText: String, link: String?) -> Idea {
        let createdAt = Date()
        let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        // Classification is best-effort: saving must never depend on enrichment quality.
        let classification = IdeaClassifier.classify(trimmedText)

        return Idea(
            id: UUID().uuidString,
            rawText: trimmedText,
            title: classification.title,
            link: normalizeOptionalLink(link),
            category: classification.category,
            status: .pending,
            discardedReason: nil,
            dateType: .none,
            dateStart: nil,
            dateEnd: nil,
            flexibleNote: nil,
            locationName: nil,
            latitude: nil,
            longitude: nil,
            address: nil,
            idealConditions: classification.idealConditions,
            notes: nil,
            createdByUserId: nil,
            ownerUserId: nil,
            groupId: nil,
            createdAt: createdAt,
            updatedAt: createdAt,
            completedAt: nil,
            lastSuggestedAt: nil,
            lastRepeatedAt: nil
        )
    }

    private func persist() {
        guard let data = try? encoder.encode(ideas) else { return }
        defaults.set(data, forKey: storageKey)
    }
}

func normalizeOptionalLink(_ value: String?) -> String? {
    guard let value else { return nil }
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

    if trimmed.isEmpty {
        return nil
    }

    if trimmed.lowercased().hasPrefix("http://") || trimmed.lowercased().hasPrefix("https://") {
        return trimmed
    }

    return "https://\(trimmed)"
}

private extension Idea {
    mutating func applyStatus(_ status: IdeaStatus) {
        self.status = status
        let timestamp = Date()

        if status == .done || status == .repeatable {
            completedAt = timestamp
            lastRepeatedAt = status == .repeatable ? timestamp : nil
        }

        if status == .discarded {
            discardedReason = .manual
        }
    }
}
