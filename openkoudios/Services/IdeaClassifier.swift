import Foundation

enum IdeaClassifier {
    private static let categoryKeywordsByLanguage: [String: [(IdeaCategory, [String])]] = [
        "es": [
            (.food, ["restaurante", "cena", "brunch", "cafe", "cafeteria", "postre", "helado", "comida", "almuerzo"]),
            (.places, ["museo", "bar", "discoteca", "rooftop", "parque", "mirador", "mercado", "tienda", "playa"]),
            (.events, ["evento", "concierto", "exhibicion", "exposicion", "festival", "teatro", "obra", "feria", "pop-up"]),
            (.plans, ["picnic", "jugar", "nintendo", "switch", "cocinar", "caminata", "caminar", "roadtrip", "noche de juegos", "pelicula", "cine en casa"]),
        ],
        "en": [
            (.food, ["restaurant", "dinner", "lunch", "brunch", "coffee", "cafe", "dessert", "ice cream", "food"]),
            (.places, ["museum", "bar", "club", "rooftop", "park", "viewpoint", "market", "shop", "beach"]),
            (.events, ["event", "concert", "exhibition", "festival", "theater", "theatre", "play", "fair", "pop-up"]),
            (.plans, ["picnic", "play", "nintendo", "switch", "cook", "hike", "walk", "roadtrip", "game night", "movie", "home cinema"]),
        ],
    ]

    private static let conditionKeywordsByLanguage: [String: [(IdealCondition, [String])]] = [
        "es": [
            (.goodWeather, ["buen clima", "sol", "soleado", "haga bueno"]),
            (.indoor, ["lluvia", "llueva", "adentro", "indoor", "casa"]),
            (.outdoor, ["afuera", "aire libre", "parque", "picnic", "playa", "outdoor"]),
            (.night, ["noche", "discoteca", "bar"]),
            (.day, ["dia", "tarde", "brunch", "cafe"]),
            (.weekend, ["fin de semana", "sabado", "domingo"]),
            (.cheap, ["barato", "gratis", "economico"]),
            (.reservationNeeded, ["reserva", "reservar"]),
        ],
        "en": [
            (.goodWeather, ["good weather", "sunny", "sun", "nice weather"]),
            (.indoor, ["rain", "raining", "inside", "indoor", "home"]),
            (.outdoor, ["outside", "outdoors", "open air", "park", "picnic", "beach"]),
            (.night, ["night", "club", "bar"]),
            (.day, ["day", "afternoon", "brunch", "coffee"]),
            (.weekend, ["weekend", "saturday", "sunday"]),
            (.cheap, ["cheap", "free", "affordable", "budget"]),
            (.reservationNeeded, ["reservation", "book", "booking", "reserve"]),
        ],
    ]

    static func classify(_ rawText: String) -> ClassificationResult {
        let normalized = normalize(rawText)
        let languages = classificationLanguages()
        let category = classifyCategory(normalized, languages: languages)
        var conditions = Set<IdealCondition>()

        languages.forEach { language in
            conditionKeywordsByLanguage[language]?.forEach { condition, words in
                if includesAny(normalized, words) {
                    conditions.insert(condition)
                }
            }
        }

        return ClassificationResult(
            title: String(rawText.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80)),
            category: category,
            idealConditions: IdealCondition.allCases.filter { conditions.contains($0) }
        )
    }

    private static func includesAny(_ text: String, _ words: [String]) -> Bool {
        words.contains { includes(text, keyword: normalize($0)) }
    }

    private static func classifyCategory(_ text: String, languages: [String]) -> IdeaCategory {
        let scores = languages.reduce(into: [IdeaCategory: Int]()) { scores, language in
            categoryKeywordsByLanguage[language]?.forEach { category, words in
                let matches = words.filter { includes(text, keyword: normalize($0)) }.count
                scores[category, default: 0] += matches
            }
        }

        return [IdeaCategory.food, .places, .events, .plans]
            .max { left, right in
                let leftScore = scores[left, default: 0]
                let rightScore = scores[right, default: 0]
                if leftScore != rightScore {
                    return leftScore < rightScore
                }
                return false
            }
            .flatMap { scores[$0, default: 0] > 0 ? $0 : nil } ?? .other
    }

    private static func includes(_ text: String, keyword: String) -> Bool {
        if keyword.contains(" ") || keyword.contains("-") {
            return text.contains(keyword)
        }

        let words = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return words.contains(keyword)
    }

    private static func normalize(_ text: String) -> String {
        text.lowercased()
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }

    private static func classificationLanguages() -> [String] {
        var languages: [String] = []
        if let currentLanguage = Locale.current.language.languageCode?.identifier {
            languages.append(currentLanguage)
        }
        languages.append(contentsOf: ["es", "en"])
        return languages.reduce(into: []) { uniqueLanguages, language in
            if !uniqueLanguages.contains(language) {
                uniqueLanguages.append(language)
            }
        }
    }
}
