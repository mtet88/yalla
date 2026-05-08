import SwiftUI

struct AppRootView: View {
    @State private var store = IdeaStore()
    @State private var selectedTab: AppTab = .vamos
    @State private var showingSave = false

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

            if selectedTab == .vamos || selectedTab == .ideas {
                Button {
                    showingSave = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(.white)
                        .frame(width: 68, height: 68)
                        .background(.green, in: Circle())
                        .shadow(color: .green.opacity(0.35), radius: 18, y: 8)
                }
                .padding(.trailing, 24)
                .padding(.bottom, 72)
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
