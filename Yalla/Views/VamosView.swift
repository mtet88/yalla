import SwiftUI

struct VamosView: View {
    let store: IdeaStore
    let showSave: () -> Void

    @State private var selectedMoment: SuggestionMoment = .today
    @State private var selectedDate = Date()
    @State private var presentedIdea: PresentedIdea?
    @Environment(\.locale) private var locale

    private var suggestions: [ScoredIdea] {
        IdeaScoring.suggestions(from: store.ideas, context: SuggestionContext(moment: selectedMoment, targetDate: selectedDate), locale: locale)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    MomentPicker(selection: $selectedMoment)

                    if selectedMoment == .date {
                        DatePicker("Elige fecha", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .font(.subheadline)
                    }
                }

                if store.ideas.isEmpty {
                    EmptyStateView(
                        title: "Aqui apareceran tus planes",
                        bodyText: "Guarda tu primera idea y te ayudamos a decidir cuando hacerla.",
                        action: showSave
                    )
                    .frame(maxHeight: .infinity)
                } else if suggestions.isEmpty {
                    VStack(spacing: 12) {
                        Text("No hay planes listos para este momento")
                            .font(.title3.weight(.bold))
                            .multilineTextAlignment(.center)
                        Text("Prueba otro momento o guarda una nueva idea.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 72)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(suggestions) { suggestion in
                                SuggestionCard(suggestion: suggestion)
                                    .contentShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                    .onTapGesture {
                                        presentedIdea = PresentedIdea(id: suggestion.idea.id)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.vertical, 8)
                        .padding(.trailing, 20)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .contentMargins(.trailing, 20, for: .scrollContent)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Vamos!")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $presentedIdea) { presentedIdea in
            NavigationStack {
                IdeaDetailView(store: store, ideaID: presentedIdea.id)
            }
        }
    }
}

private struct PresentedIdea: Identifiable {
    let id: Idea.ID
}

private struct MomentPicker: View {
    @Binding var selection: SuggestionMoment

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SuggestionMoment.allCases) { moment in
                    Button {
                        selection = moment
                    } label: {
                        Text(moment.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(selection == moment ? Color.white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(selection == moment ? Color.selectedChipBackground : Color.chipBackground, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(selection == moment ? "Seleccionado" : "")
                }
            }
            .padding(.vertical, 2)
        }
    }
}

private struct SuggestionCard: View {
    let suggestion: ScoredIdea

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .center) {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: suggestion.idea.category.symbolName)
                    .font(.system(size: 70, weight: .light))
                    .foregroundStyle(.white.opacity(0.75))
                VStack {
                    HStack {
                        CategoryBadge(category: suggestion.idea.category)
                        Spacer()
                        ShareLink(item: "\(String(localized: "Hacemos esto?", locale: locale))\n\(suggestion.idea.title)\n\(suggestion.reasons.first?.localizedString(locale: locale) ?? "")") {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .frame(width: 34, height: 34)
                                .background(.thinMaterial, in: Circle())
                        }
                    }
                    Spacer()
                }
                .padding(14)
            }
            .frame(height: 260)

            VStack(alignment: .leading, spacing: 8) {
                Text(suggestion.idea.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                SuggestionReasonText(reason: suggestion.reasons.first ?? .pendingList, locale: locale)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding(18)
            .frame(height: 150, alignment: .topLeading)
        }
        .frame(width: 320)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 16, y: 7)
    }

    private var colors: [Color] {
        switch suggestion.idea.category {
        case .food: [.orange.opacity(0.45), .pink.opacity(0.25), .cardBackground]
        case .places: [.green.opacity(0.45), .cyan.opacity(0.25), .cardBackground]
        case .events: [.purple.opacity(0.45), .cyan.opacity(0.25), .cardBackground]
        case .plans: [.green.opacity(0.45), .yellow.opacity(0.25), .cardBackground]
        case .other: [.gray.opacity(0.35), .cyan.opacity(0.2), .cardBackground]
        }
    }
}

private struct SuggestionReasonText: View {
    let reason: SuggestionReason
    let locale: Locale

    var body: some View {
        switch reason {
        case .pendingOverThirtyDays:
            Text("Lleva mas de 30 dias pendiente.")
        case .repeatableReady:
            Text("Es repetible y ya puede volver a sugerirse.")
        case .weekendFit:
            Text("Encaja con planes de fin de semana.")
        case .weatherFit:
            Text("Puede ser buen plan cuando el clima acompane.")
        case .event:
            Text("Es un evento, conviene tenerlo presente.")
        case .pendingList:
            Text("Esta en tu lista de ideas pendientes.")
        case .incompleteSingleDate:
            Text("Tiene una fecha especifica por completar.")
        case .matchingDate, .approachingDate, .incompleteRange, .withinRange, .startsSoon:
            Text(reason.localizedString(locale: locale))
        }
    }
}
