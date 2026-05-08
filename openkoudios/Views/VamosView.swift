import SwiftUI

struct VamosView: View {
    let store: IdeaStore
    let showSave: () -> Void

    @State private var selectedMoment: SuggestionMoment = .today
    @State private var selectedDate = Date()

    private var suggestions: [ScoredIdea] {
        IdeaScoring.suggestions(from: store.ideas, context: SuggestionContext(moment: selectedMoment, targetDate: selectedDate))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Cuando:")
                            .font(.title3.weight(.black))
                        Picker("Cuando", selection: $selectedMoment) {
                            ForEach(SuggestionMoment.allCases) { moment in
                                Text(moment.label).tag(moment)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black, in: Capsule())
                        .tint(.white)
                    }

                    if selectedMoment == .date {
                        DatePicker("Elige fecha", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
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
                            .font(.title2.weight(.black))
                            .multilineTextAlignment(.center)
                        Text("Prueba otro momento o guarda una nueva idea.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 120)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 18) {
                            ForEach(suggestions) { suggestion in
                                NavigationLink(value: suggestion.idea.id) {
                                    SuggestionCard(suggestion: suggestion)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(24)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Vamos!")
        .navigationDestination(for: Idea.ID.self) { id in
            IdeaDetailView(store: store, ideaID: id)
        }
    }
}

private struct SuggestionCard: View {
    let suggestion: ScoredIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: suggestion.idea.category.symbolName)
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(.white.opacity(0.8))
                VStack {
                    HStack {
                        CategoryBadge(category: suggestion.idea.category)
                        Spacer()
                        ShareLink(item: "Hacemos esto?\n\(suggestion.idea.title)\n\(suggestion.reasons.first ?? "")") {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(.white)
                                .padding(10)
                                .background(.black, in: Circle())
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .frame(height: 260)

            VStack(alignment: .leading, spacing: 10) {
                Text(suggestion.idea.title)
                    .font(.title2.weight(.black))
                    .foregroundStyle(.primary)
                Text(suggestion.reasons.first ?? "Esta en tu lista de ideas pendientes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
        }
        .frame(width: 320)
        .background(.white, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 18, y: 8)
    }

    private var colors: [Color] {
        switch suggestion.idea.category {
        case .food: [.orange.opacity(0.45), .pink.opacity(0.25), .white]
        case .places: [.green.opacity(0.45), .cyan.opacity(0.25), .white]
        case .events: [.purple.opacity(0.45), .cyan.opacity(0.25), .white]
        case .plans: [.green.opacity(0.45), .yellow.opacity(0.25), .white]
        case .other: [.gray.opacity(0.35), .cyan.opacity(0.2), .white]
        }
    }
}
