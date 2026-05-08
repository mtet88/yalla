import Foundation

enum IdeaClassifier {
    private static let categoryKeywords: [(IdeaCategory, [String])] = [
        (.food, ["restaurante", "cena", "brunch", "cafe", "cafeteria", "postre", "helado", "comida", "almuerzo"]),
        (.places, ["museo", "bar", "discoteca", "rooftop", "parque", "mirador", "mercado", "tienda", "playa"]),
        (.events, ["evento", "concierto", "exhibicion", "exposicion", "festival", "teatro", "obra", "feria", "pop-up"]),
        (.plans, ["picnic", "jugar", "nintendo", "switch", "cocinar", "caminata", "caminar", "roadtrip", "noche de juegos", "pelicula", "cine en casa"]),
    ]

    static func classify(_ rawText: String) -> ClassificationResult {
        let normalized = normalize(rawText)
        let category = categoryKeywords.first { _, words in includesAny(normalized, words) }?.0 ?? .other
        var conditions = Set<IdealCondition>()

        if includesAny(normalized, ["buen clima", "sol", "soleado", "haga bueno"]) {
            conditions.insert(.goodWeather)
        }

        if includesAny(normalized, ["lluvia", "llueva", "adentro", "indoor", "casa"]) {
            conditions.insert(.indoor)
        }

        if includesAny(normalized, ["afuera", "aire libre", "parque", "picnic", "playa", "outdoor"]) {
            conditions.insert(.outdoor)
        }

        if includesAny(normalized, ["noche", "discoteca", "bar"]) {
            conditions.insert(.night)
        }

        if includesAny(normalized, ["dia", "tarde", "brunch", "cafe"]) {
            conditions.insert(.day)
        }

        if includesAny(normalized, ["fin de semana", "sabado", "domingo"]) {
            conditions.insert(.weekend)
        }

        if includesAny(normalized, ["barato", "gratis", "economico"]) {
            conditions.insert(.cheap)
        }

        if includesAny(normalized, ["reserva", "reservar"]) {
            conditions.insert(.reservationNeeded)
        }

        return ClassificationResult(
            title: String(rawText.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80)),
            category: category,
            idealConditions: IdealCondition.allCases.filter { conditions.contains($0) }
        )
    }

    private static func includesAny(_ text: String, _ words: [String]) -> Bool {
        words.contains { text.contains($0) }
    }

    private static func normalize(_ text: String) -> String {
        text.lowercased(with: Locale(identifier: "es"))
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es"))
    }
}
