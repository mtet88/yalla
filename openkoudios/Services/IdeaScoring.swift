import Foundation

enum IdeaScoring {
    static func suggestions(from ideas: [Idea], context: SuggestionContext = SuggestionContext()) -> [ScoredIdea] {
        ideas.compactMap { idea in
            guard canSuggest(idea) else { return nil }

            var reasons: [String] = []
            var score = 10
            let age = daysBetween(idea.createdAt)
            let dateFit = getDateFit(idea: idea, context: context)

            guard dateFit.applies else { return nil }

            score += dateFit.score

            if let reason = dateFit.reason, !reason.isEmpty {
                reasons.append(reason)
            }

            if idea.status == .pending {
                score += 10
            }

            if age > 30 {
                score += 15
                reasons.append("Lleva mas de 30 dias pendiente.")
            }

            if idea.status == .repeatable {
                score += 10
                reasons.append("Es repetible y ya puede volver a sugerirse.")
            }

            if context.moment == .weekend && idea.idealConditions.contains(.weekend) {
                score += 14
                reasons.append("Encaja con planes de fin de semana.")
            }

            if idea.idealConditions.contains(.goodWeather) || idea.idealConditions.contains(.outdoor) {
                score += 8
                reasons.append("Puede ser buen plan cuando el clima acompane.")
            }

            if idea.category == .events {
                score += 8
                reasons.append("Es un evento, conviene tenerlo presente.")
            }

            if reasons.isEmpty {
                reasons.append("Esta en tu lista de ideas pendientes.")
            }

            return ScoredIdea(idea: idea, score: score, reasons: reasons)
        }
        .sorted {
            if $0.score != $1.score {
                return $0.score > $1.score
            }

            return $0.idea.createdAt > $1.idea.createdAt
        }
        .prefix(5)
        .map { $0 }
    }

    private static func canSuggest(_ idea: Idea) -> Bool {
        if idea.status == .done || idea.status == .discarded {
            return false
        }

        // Product rule: repeatable plans need a cooldown before they can reappear.
        if idea.status == .repeatable {
            guard let anchor = idea.lastRepeatedAt ?? idea.completedAt else { return true }
            return daysBetween(anchor) >= 15
        }

        return true
    }

    private static func getDateFit(idea: Idea, context: SuggestionContext) -> (applies: Bool, score: Int, reason: String?) {
        let target = targetRange(for: context)
        let allowsNearFuture = context.moment == .weekend
        let allowsFallback = idea.dateType == .none || idea.dateType == .flexible

        switch idea.dateType {
        case .single:
            guard let date = idea.dateStart else {
                return (true, 0, "Tiene una fecha especifica por completar.")
            }

            if overlaps(start: date, end: date, targetStart: target.start, targetEnd: target.end) {
                return (true, 35, "Cae en este momento: \(formatDate(date)).")
            }

            guard allowsNearFuture else { return (false, 0, nil) }

            let daysAway = Calendar.current.dateComponents([.day], from: target.end, to: startOfDay(date)).day ?? 0
            if daysAway >= 0 && daysAway <= 7 {
                return (true, 12, "Se acerca: \(formatDate(date)).")
            }

            return (false, 0, nil)
        case .range:
            guard let start = idea.dateStart else {
                return (true, 0, "Tiene un rango de fechas por completar.")
            }

            let end = idea.dateEnd ?? start
            if overlaps(start: start, end: end, targetStart: target.start, targetEnd: target.end) {
                return (true, 32, "Esta dentro del rango de fechas.")
            }

            guard allowsNearFuture else { return (false, 0, nil) }

            let daysAway = Calendar.current.dateComponents([.day], from: target.end, to: startOfDay(start)).day ?? 0
            if daysAway >= 0 && daysAway <= 7 {
                return (true, 10, "Empieza pronto: \(formatDate(start)).")
            }

            return (false, 0, nil)
        case .flexible:
            if let note = idea.flexibleNote, !note.isEmpty {
                return (true, 4, "Flexible: \(note).")
            }

            return (true, 4, "Es flexible para este momento.")
        case .none:
            return (allowsFallback, 0, nil)
        }
    }

    private static func targetRange(for context: SuggestionContext) -> (start: Date, end: Date) {
        let today = startOfDay(Date())

        switch context.moment {
        case .tomorrow:
            let target = addDays(today, 1)
            return (target, target)
        case .weekend:
            return weekendRange(from: today)
        case .date:
            let target = startOfDay(context.targetDate)
            return (target, target)
        case .today:
            return (today, today)
        }
    }

    private static func weekendRange(from today: Date) -> (start: Date, end: Date) {
        let weekday = Calendar.current.component(.weekday, from: today)
        let daysUntilSaturday = weekday == 1 ? -1 : 7 - weekday
        let start = addDays(today, daysUntilSaturday)
        return (start, addDays(start, 1))
    }

    private static func overlaps(start: Date, end: Date, targetStart: Date, targetEnd: Date) -> Bool {
        startOfDay(start) <= startOfDay(targetEnd) && startOfDay(end) >= startOfDay(targetStart)
    }

    private static func daysBetween(_ from: Date, to: Date = Date()) -> Int {
        Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
    }

    private static func startOfDay(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private static func addDays(_ date: Date, _ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: startOfDay(date)) ?? date
    }

    private static func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year())
    }
}
