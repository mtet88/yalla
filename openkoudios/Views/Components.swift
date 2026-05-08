import SwiftUI

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
                .foregroundStyle(.green)
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let action {
                Button("Guardar primera idea", action: action)
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.gray.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [6]))
        )
    }
}

struct IdeaCardView: View {
    let idea: Idea
    var delete: (() -> Void)?

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
                        .background(.black, in: Circle())
                }
            }

            Text(idea.title)
                .font(.headline.weight(.black))
                .foregroundStyle(.primary)

            if let summary = idea.dateSummary {
                Label(summary, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let locationName = idea.locationName, !locationName.isEmpty {
                Label(locationName, systemImage: "mappin")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }
}

extension Idea {
    var dateSummary: String? {
        switch dateType {
        case .none:
            nil
        case .single:
            dateStart.map { "Fecha: \($0.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year()))" } ?? "Fecha especifica sin definir"
        case .range:
            if let dateStart, let dateEnd {
                "\(dateStart.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year())) - \(dateEnd.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year()))"
            } else if let dateStart {
                "Desde \(dateStart.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year()))"
            } else if let dateEnd {
                "Hasta \(dateEnd.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year()))"
            } else {
                "Rango sin definir"
            }
        case .flexible:
            flexibleNote?.isEmpty == false ? flexibleNote : "Flexible"
        }
    }
}

extension Color {
    static let appBackground = Color(red: 0.93, green: 0.98, blue: 1.0)
}
