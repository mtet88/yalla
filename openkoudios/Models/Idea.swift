import Foundation
import SwiftUI

enum IdeaCategory: String, Codable, CaseIterable, Identifiable {
    case food
    case places
    case events
    case plans
    case other

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .food: "Comida"
        case .places: "Sitios"
        case .events: "Eventos"
        case .plans: "Planes"
        case .other: "Otro"
        }
    }

    var symbolName: String {
        switch self {
        case .food: "fork.knife"
        case .places: "mappin.and.ellipse"
        case .events: "ticket"
        case .plans: "sparkles"
        case .other: "star"
        }
    }
}

enum IdeaStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case done
    case repeatable
    case discarded

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .pending: "Pendiente"
        case .done: "Hecha"
        case .repeatable: "Repetible"
        case .discarded: "Descartada"
        }
    }
}

enum IdeaDateType: String, Codable, CaseIterable, Identifiable {
    case none
    case single
    case range

    var id: String { rawValue }

    static var editableCases: [IdeaDateType] {
        allCases
    }

    var label: LocalizedStringKey {
        switch self {
        case .none: "Sin fecha"
        case .single: "Fecha especifica"
        case .range: "Rango"
        }
    }
}

enum DiscardedReason: String, Codable {
    case manual
    case expired
}

enum IdealCondition: String, Codable, CaseIterable, Identifiable {
    case goodWeather = "good_weather"
    case indoor
    case outdoor
    case day
    case night
    case weekend
    case cheap
    case reservationNeeded = "reservation_needed"

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .goodWeather: "Buen clima"
        case .indoor: "Indoor"
        case .outdoor: "Outdoor"
        case .day: "Dia"
        case .night: "Noche"
        case .weekend: "Fin de semana"
        case .cheap: "Barato"
        case .reservationNeeded: "Reserva necesaria"
        }
    }
}

struct Idea: Identifiable, Codable, Hashable {
    var id: String
    var rawText: String
    var title: String
    var link: String?
    var category: IdeaCategory
    var status: IdeaStatus
    var discardedReason: DiscardedReason?
    var dateType: IdeaDateType
    var dateStart: Date?
    var dateEnd: Date?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var idealConditions: [IdealCondition]
    var notes: String?
    var createdByUserId: String?
    var ownerUserId: String?
    var groupId: String?
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var lastSuggestedAt: Date?
    var lastRepeatedAt: Date?
}

struct IdeaInput {
    var rawText: String
    var link: String?
}

struct ClassificationResult {
    var title: String
    var category: IdeaCategory
    var idealConditions: [IdealCondition]
}

enum SuggestionMoment: String, CaseIterable, Identifiable {
    case today
    case tomorrow
    case weekend
    case date

    var id: String { rawValue }

    var label: LocalizedStringKey {
        switch self {
        case .today: "Hoy"
        case .tomorrow: "Mañana"
        case .weekend: "Fin de semana"
        case .date: "Fecha"
        }
    }
}

struct SuggestionContext {
    var moment: SuggestionMoment = .today
    var targetDate: Date = Date()
}

struct ScoredIdea: Identifiable {
    var id: String { idea.id }
    var idea: Idea
    var score: Int
    var reasons: [SuggestionReason]
}

enum SuggestionReason: Equatable {
    case pendingOverThirtyDays
    case repeatableReady
    case weekendFit
    case weatherFit
    case event
    case pendingList
    case incompleteSingleDate
    case matchingDate(Date)
    case approachingDate(Date)
    case incompleteRange
    case withinRange
    case startsSoon(Date)

    func localizedString(locale: Locale) -> String {
        switch self {
        case .pendingOverThirtyDays:
            String(localized: "Lleva mas de 30 dias pendiente.", locale: locale)
        case .repeatableReady:
            String(localized: "Es repetible y ya puede volver a sugerirse.", locale: locale)
        case .weekendFit:
            String(localized: "Encaja con planes de fin de semana.", locale: locale)
        case .weatherFit:
            String(localized: "Puede ser buen plan cuando el clima acompane.", locale: locale)
        case .event:
            String(localized: "Es un evento, conviene tenerlo presente.", locale: locale)
        case .pendingList:
            String(localized: "Esta en tu lista de ideas pendientes.", locale: locale)
        case .incompleteSingleDate:
            String(localized: "Tiene una fecha especifica por completar.", locale: locale)
        case .matchingDate(let date):
            "\(String(localized: "Cae en este momento", locale: locale)): \(formatDate(date, locale: locale))."
        case .approachingDate(let date):
            "\(String(localized: "Se acerca", locale: locale)): \(formatDate(date, locale: locale))."
        case .incompleteRange:
            String(localized: "Tiene un rango de fechas por completar.", locale: locale)
        case .withinRange:
            String(localized: "Esta dentro del rango de fechas.", locale: locale)
        case .startsSoon(let date):
            "\(String(localized: "Empieza pronto", locale: locale)): \(formatDate(date, locale: locale))."
        }
    }

    private func formatDate(_ date: Date, locale: Locale) -> String {
        date.formatted(.dateTime.locale(locale).day().month().year())
    }
}
