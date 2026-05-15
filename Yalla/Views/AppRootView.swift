import SwiftUI

struct AppRootView: View {
    @State private var store: IdeaStore
    @State private var selectedTab: AppTab = .vamos
    @State private var showingSave = false

    init(store: IdeaStore = IdeaStore()) {
        _store = State(initialValue: store)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    VamosView(store: store, showSave: { showingSave = true })
                }
                .tabItem { Label("Vamos!", systemImage: "safari") }
                .tag(AppTab.vamos)

                NavigationStack {
                    IdeasListView(store: store, showSave: { showingSave = true })
                }
                .tabItem { Label("Ideas", systemImage: "lightbulb") }
                .tag(AppTab.ideas)

                NavigationStack {
                    AccountView()
                }
                .tabItem { Label("Cuenta", systemImage: "person") }
                .tag(AppTab.account)
            }
            .tint(.yallaPrimary)

            if selectedTab == .vamos || selectedTab == .ideas {
                Button {
                    showingSave = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.yallaPrimary, in: Circle())
                        .shadow(color: Color.yallaPrimary.opacity(0.28), radius: 16, y: 8)
                }
                .padding(.trailing, 22)
                .padding(.bottom, 78)
                .accessibilityLabel("Guardar idea")
            }
        }
        .sheet(isPresented: $showingSave) {
            NavigationStack {
                SaveIdeaView(store: store)
            }
        }
    }
}

private enum AppTab {
    case vamos
    case ideas
    case account
}
