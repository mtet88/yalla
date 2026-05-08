import Foundation

enum IdeaExpiration {
    static func expirePastIdeas(_ ideas: [Idea], now: Date = Date()) -> (ideas: [Idea], changed: Bool) {
        var changed = false
        let today = Calendar.current.startOfDay(for: now)

        let nextIdeas = ideas.map { idea in
            if idea.status == .done || idea.status == .repeatable || idea.status == .discarded {
                return idea
            }

            guard let expirationDate = expirationDate(for: idea) else {
                return idea
            }

            if today <= expirationDate {
                return idea
            }

            changed = true
            var expired = idea
            // Expired plans stay in the archive; they are never deleted automatically.
            expired.status = .discarded
            expired.discardedReason = .expired
            expired.updatedAt = now
            return expired
        }

        return (nextIdeas, changed)
    }

    private static func expirationDate(for idea: Idea) -> Date? {
        switch idea.dateType {
        case .single:
            guard let date = idea.dateStart else { return nil }
            return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))
        case .range:
            guard let date = idea.dateEnd ?? idea.dateStart else { return nil }
            return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: date))
        case .none, .flexible:
            return nil
        }
    }
}
