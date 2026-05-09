import SwiftUI

struct SaveIdeaView: View {
    let store: IdeaStore

    @Environment(\.dismiss) private var dismiss
    @State private var rawText = ""
    @State private var link = ""
    @State private var error = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tira cualquier plan aqui.")
                        .font(.largeTitle.weight(.black))
                    Text("Puede ser un restaurante, evento, sitio o algo como jugar Nintendo Switch en casa.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Que idea quieres guardar?")
                        .font(.headline)
                    TextEditor(text: $rawText)
                        .frame(minHeight: 150)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color.softBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(alignment: .topLeading) {
                            if rawText.isEmpty {
                                Text("Picnic en el parque cuando haga buen clima")
                                    .foregroundStyle(Color.secondaryText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Link opcional")
                        .font(.headline)
                    TextField("https://...", text: $link)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .padding(14)
                        .background(Color.softBackground, in: Capsule())
                }

                if !error.isEmpty {
                    Text(error)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.red)
                }

                PrimaryCTAButton(title: "Guardar idea", action: save)
            }
            .padding(24)
            .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Guardar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }
        }
    }

    private func save() {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            error = "Escribe una idea para guardarla."
            return
        }

        _ = store.addIdea(rawText: text, link: link)
        dismiss()
    }
}
