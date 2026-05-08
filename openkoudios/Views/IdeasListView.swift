import SwiftUI

struct IdeasListView: View {
    let store: IdeaStore
    let showSave: () -> Void

    @State private var activeFilter: IdeaFilter = .all
    @State private var deletingIdea: Idea?
    @State private var presentedIdea: PresentedIdea?

    private var visibleIdeas: [Idea] {
        store.ideas
            .filter { activeFilter.matches($0) }
            .sorted(by: sortIdeas)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(IdeaFilter.allCases) { filter in
                            Button(filter.label) {
                                activeFilter = filter
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(activeFilter == filter ? Color.white : Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(activeFilter == filter ? Color.black : Color.white, in: Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }

                if store.ideas.isEmpty {
                    EmptyStateView(title: "Aun no hay ideas", bodyText: "Guarda algo que algun dia quieras hacer con amigos.", action: showSave)
                } else if visibleIdeas.isEmpty {
                    EmptyStateView(title: "No hay ideas con este filtro", bodyText: "Prueba otro filtro o guarda una idea nueva.")
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(visibleIdeas) { idea in
                            IdeaCardView(idea: idea) {
                                deletingIdea = idea
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .onTapGesture {
                                presentedIdea = PresentedIdea(id: idea.id)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Ideas")
        .sheet(item: $presentedIdea) { presentedIdea in
            NavigationStack {
                IdeaDetailView(store: store, ideaID: presentedIdea.id)
            }
        }
        .alert("Borrar esta idea?", isPresented: Binding(get: { deletingIdea != nil }, set: { if !$0 { deletingIdea = nil } })) {
            Button("Borrar", role: .destructive) {
                if let deletingIdea {
                    store.deleteIdea(deletingIdea)
                }
                deletingIdea = nil
            }
            Button("Cancelar", role: .cancel) {
                deletingIdea = nil
            }
        }
    }

    private func sortIdeas(_ left: Idea, _ right: Idea) -> Bool {
        if left.status == .pending && right.status != .pending { return true }
        if left.status != .pending && right.status == .pending { return false }
        if left.status == .discarded && right.status != .discarded { return false }
        if left.status != .discarded && right.status == .discarded { return true }
        return left.createdAt > right.createdAt
    }
}

private struct PresentedIdea: Identifiable {
    let id: Idea.ID
}

enum IdeaFilter: Hashable, CaseIterable, Identifiable {
    case all
    case status(IdeaStatus)
    case category(IdeaCategory)

    var id: String {
        switch self {
        case .all: "all"
        case .status(let status): status.rawValue
        case .category(let category): category.rawValue
        }
    }

    var label: String {
        switch self {
        case .all: "Todas"
        case .status(let status): status == .pending ? "Pendientes" : status.label + "s"
        case .category(let category): category.label
        }
    }

    static var allCases: [IdeaFilter] {
        [.all, .status(.pending), .status(.repeatable), .status(.done), .status(.discarded), .category(.food), .category(.places), .category(.events), .category(.plans), .category(.other)]
    }

    func matches(_ idea: Idea) -> Bool {
        switch self {
        case .all: true
        case .status(let status): idea.status == status
        case .category(let category): idea.category == category
        }
    }
}
