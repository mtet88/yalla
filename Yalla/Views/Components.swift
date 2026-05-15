import SwiftUI
import UIKit

struct CategoryBadge: View {
    let category: IdeaCategory

    var body: some View {
        Label(category.label, systemImage: category.symbolName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }
}

struct StatusBadge: View {
    let status: IdeaStatus

    var body: some View {
        Text(status.label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(background, in: Capsule())
    }

    private var foreground: Color {
        switch status {
        case .pending: .blue
        case .done: .green
        case .repeatable: .orange
        case .discarded: .secondary
        }
    }

    private var background: Color {
        switch status {
        case .pending: .blue.opacity(0.12)
        case .done: .green.opacity(0.12)
        case .repeatable: .orange.opacity(0.14)
        case .discarded: .gray.opacity(0.14)
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let bodyText: String
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(Color.yallaPrimary)
            Text(LocalizedStringKey(title))
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(LocalizedStringKey(bodyText))
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)

            if let action {
                Button("Guardar primera idea", action: action)
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                    .tint(.yallaPrimary)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(Color.cardBackground.opacity(0.75), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.border.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [6]))
        )
    }
}

struct IdeaCardView: View {
    let idea: Idea
    var delete: (() -> Void)?

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                HStack(spacing: 8) {
                    CategoryBadge(category: idea.category)
                    StatusBadge(status: idea.status)
                }
                Spacer()
                if idea.link != nil {
                    Image(systemName: "link")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.iconButtonBackground, in: Circle())
                }
            }

            Text(idea.title)
                .font(.headline.weight(.black))
                .foregroundStyle(.primary)

            if let summary = idea.dateSummary(locale: locale) {
                Label(summary, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            if let locationName = idea.locationName, !locationName.isEmpty {
                Label(locationName, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            if let delete {
                HStack {
                    Spacer()
                    Button("Borrar", role: .destructive, action: delete)
                        .font(.subheadline.weight(.bold))
                        .buttonStyle(.bordered)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }
}

extension Idea {
    func dateSummary(locale: Locale) -> String? {
        switch dateType {
        case .none:
            return nil
        case .single:
            return dateStart.map { formatDate($0, locale: locale) } ?? localized("Fecha especifica sin definir", locale: locale)
        case .range:
            if let dateStart, let dateEnd {
                return "\(formatDate(dateStart, locale: locale)) - \(formatDate(dateEnd, locale: locale))"
            } else if let dateStart {
                let formattedDate = formatDate(dateStart, locale: locale)
                return "\(localized("Desde", locale: locale)) \(formattedDate)"
            } else if let dateEnd {
                let formattedDate = formatDate(dateEnd, locale: locale)
                return "\(localized("Hasta", locale: locale)) \(formattedDate)"
            } else {
                return localized("Rango sin definir", locale: locale)
            }
        }
    }

    private func localized(_ key: String.LocalizationValue, locale: Locale) -> String {
        String(localized: key, locale: locale)
    }

    private func formatDate(_ date: Date, locale: Locale) -> String {
        date.formatted(.dateTime.locale(locale).day().month().year())
    }
}

extension Color {
    static let yallaPrimary = adaptive(light: UIColor(red: 1.00, green: 0.42, blue: 0.24, alpha: 1), dark: UIColor(red: 1.00, green: 0.55, blue: 0.30, alpha: 1))
    static let yallaPrimarySoft = adaptive(light: UIColor(red: 1.00, green: 0.42, blue: 0.24, alpha: 0.14), dark: UIColor(red: 1.00, green: 0.55, blue: 0.30, alpha: 0.22))
    static let appBackground = adaptive(light: UIColor(red: 0.93, green: 0.98, blue: 1.00, alpha: 1), dark: UIColor(red: 0.06, green: 0.09, blue: 0.11, alpha: 1))
    static let cardBackground = adaptive(light: UIColor.white, dark: UIColor(red: 0.12, green: 0.15, blue: 0.17, alpha: 1))
    static let softBackground = adaptive(light: UIColor(red: 0.95, green: 0.96, blue: 0.97, alpha: 1), dark: UIColor(red: 0.18, green: 0.22, blue: 0.25, alpha: 1))
    static let chipBackground = adaptive(light: UIColor.white.withAlphaComponent(0.88), dark: UIColor(red: 0.17, green: 0.21, blue: 0.24, alpha: 1))
    static let selectedChipBackground = adaptive(light: UIColor.black, dark: UIColor(red: 1.00, green: 0.55, blue: 0.30, alpha: 1))
    static let iconButtonBackground = adaptive(light: UIColor.black, dark: UIColor(red: 1.00, green: 0.55, blue: 0.30, alpha: 1))
    static let secondaryText = adaptive(light: UIColor.secondaryLabel, dark: UIColor(red: 0.70, green: 0.76, blue: 0.80, alpha: 1))
    static let border = adaptive(light: UIColor(red: 0.77, green: 0.83, blue: 0.86, alpha: 1), dark: UIColor(red: 0.27, green: 0.33, blue: 0.37, alpha: 1))

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
}
