import SwiftUI

struct AccountView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Modo invitado")
                    .font(.largeTitle.weight(.black))

                VStack(alignment: .leading, spacing: 20) {
                    Text("Por ahora tus ideas se guardan en este dispositivo. El login con Google/email y la migracion a Supabase vendran despues de validar el flujo local.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)

                    Button("Continuar con Google proximamente") {}
                        .buttonStyle(.borderedProminent)
                        .tint(.black)
                        .disabled(true)

                    Button("Entrar con email proximamente") {}
                        .buttonStyle(.bordered)
                        .disabled(true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .background(.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Cuenta")
    }
}
