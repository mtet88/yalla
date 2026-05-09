import SwiftUI

struct IdeaDetailView: View {
    let store: IdeaStore
    let ideaID: Idea.ID

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var isEditing = false
    @State private var draft: IdeaDraft?
    @State private var showingDelete = false
    @State private var error = ""

    private var idea: Idea? { store.idea(with: ideaID) }

    var body: some View {
        Group {
            if let idea {
                ScrollView {
                    if isEditing {
                        editView(idea: idea)
                    } else {
                        detailView(idea: idea)
                    }
                }
                .background(Color.appBackground.ignoresSafeArea())
            } else {
                VStack(spacing: 16) {
                    Text("Idea no encontrada")
                        .font(.title2.weight(.black))
                    Text("Puede que haya sido eliminada localmente.")
                        .foregroundStyle(Color.secondaryText)
                    Button("Volver a ideas") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(.yallaPrimary)
                }
                .padding()
            }
        }
        .navigationTitle(isEditing ? "Editar idea" : "Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }

            if idea != nil && !isEditing {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        if let idea {
                            draft = IdeaDraft(idea: idea)
                        }
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    Button(role: .destructive) { showingDelete = true } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("Borrar esta idea?", isPresented: $showingDelete) {
            Button("Borrar", role: .destructive) {
                if let idea {
                    store.deleteIdea(idea)
                }
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private func detailView(idea: Idea) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(spacing: 8) {
                CategoryBadge(category: idea.category)
                Spacer()
                ShareLink(item: "Hacemos esto?\n\(idea.title)") {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Color.iconButtonBackground, in: Circle())
                }
            }

            Text(idea.title)
                .font(.largeTitle.weight(.black))

            VStack(alignment: .leading, spacing: 18) {
                DetailRow(label: "Texto original", value: idea.rawText)

                if let link = idea.link, !link.isEmpty {
                    DetailRow(label: "Link") {
                        Button(link) {
                            if let url = URL(string: link) { openURL(url) }
                        }
                        .foregroundStyle(.blue)
                    }
                }

                DetailRow(label: "Fecha", value: idea.dateSummary ?? "Sin fecha")
                DetailRow(label: "Ubicacion", value: idea.locationName?.isEmpty == false ? idea.locationName! : "Sin ubicacion todavia")

                DetailRow(label: "Condiciones ideales") {
                    if idea.idealConditions.isEmpty {
                        Text("Sin condiciones todavia")
                    } else {
                        FlowLayout(items: idea.idealConditions) { condition in
                            Text(condition.label)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.green.opacity(0.12), in: Capsule())
                                .foregroundStyle(.green)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }

                DetailRow(label: "Notas", value: idea.notes?.isEmpty == false ? idea.notes! : "Sin notas todavia")

                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Creada", value: formatDate(idea.createdAt))
                    DetailRow(label: "Ultima actualizacion", value: formatDate(idea.updatedAt))
                    DetailRow(label: "Ultima vez sugerida", value: idea.lastSuggestedAt.map(formatDate) ?? "Todavia no")
                    DetailRow(label: "Hecha", value: idea.completedAt.map(formatDate) ?? "Todavia no")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.softBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }

            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    StatusActionButton(systemName: "checkmark", active: idea.status == .done, tint: .green) {
                        store.updateStatus(for: idea, status: .done)
                    }
                    StatusActionButton(systemName: "arrow.clockwise", active: idea.status == .repeatable, tint: .orange) {
                        store.updateStatus(for: idea, status: .repeatable)
                    }
                    StatusActionButton(systemName: "xmark", active: idea.status == .discarded, tint: .gray) {
                        store.updateStatus(for: idea, status: .discarded)
                    }
                }

                Text(idea.status.label.uppercased())
                    .font(.caption.weight(.black))
                    .tracking(2)
                    .foregroundStyle(statusColor(idea.status))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(22)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding(20)
    }

    private func editView(idea: Idea) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            let draftBinding = Binding(
                get: { draft ?? IdeaDraft(idea: idea) },
                set: { draft = $0 }
            )

            HStack(spacing: 8) {
                CategoryBadge(category: draftBinding.wrappedValue.category)
                StatusBadge(status: draftBinding.wrappedValue.status)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Titulo").font(.headline)
                TextField("Titulo", text: draftBinding.title)
                    .textFieldStyle(.roundedBorder)
            }

            DetailRow(label: "Texto original", value: idea.rawText)

            Picker("Categoria", selection: draftBinding.category) {
                ForEach(IdeaCategory.allCases) { category in
                    Text(category.label).tag(category)
                }
            }

            Picker("Estado", selection: draftBinding.status) {
                ForEach(IdeaStatus.allCases) { status in
                    Text(status.label).tag(status)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Link").font(.headline)
                TextField("https://...", text: draftBinding.link)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .textFieldStyle(.roundedBorder)
            }

            Picker("Fecha", selection: draftBinding.dateType) {
                ForEach(IdeaDateType.allCases) { type in
                    Text(type.label).tag(type)
                }
            }

            if draftBinding.wrappedValue.dateType == .single || draftBinding.wrappedValue.dateType == .range {
                DatePicker("Empieza", selection: dateBinding(draftBinding.dateStart), displayedComponents: .date)
            }

            if draftBinding.wrappedValue.dateType == .range {
                DatePicker("Termina", selection: dateBinding(draftBinding.dateEnd), displayedComponents: .date)
            }

            if draftBinding.wrappedValue.dateType == .flexible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nota flexible").font(.headline)
                    TextField("Cuando haga buen clima...", text: draftBinding.flexibleNote)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Ubicacion").font(.headline)
                TextField("Nombre del sitio o zona", text: draftBinding.locationName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Condiciones ideales").font(.headline)
                FlowLayout(items: IdealCondition.allCases) { condition in
                    Button(condition.label) {
                        var next = draftBinding.wrappedValue
                        if next.idealConditions.contains(condition) {
                            next.idealConditions.removeAll { $0 == condition }
                        } else {
                            next.idealConditions.append(condition)
                        }
                        draftBinding.wrappedValue = next
                    }
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(draftBinding.wrappedValue.idealConditions.contains(condition) ? Color.green : Color.softBackground, in: Capsule())
                    .foregroundStyle(draftBinding.wrappedValue.idealConditions.contains(condition) ? Color.white : Color.primary)
                    .fixedSize(horizontal: true, vertical: false)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Notas").font(.headline)
                TextEditor(text: draftBinding.notes)
                    .frame(minHeight: 100)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.softBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            if !error.isEmpty {
                Text(error).foregroundStyle(.red).font(.subheadline.weight(.bold))
            }

            PrimaryCTAButton(title: "Guardar cambios") {
                saveDraft(original: idea)
            }
        }
        .padding(22)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding(20)
        .onAppear { draft = IdeaDraft(idea: idea) }
    }

    private func dateBinding(_ value: Binding<Date?>) -> Binding<Date> {
        Binding<Date>(
            get: { value.wrappedValue ?? Date() },
            set: { value.wrappedValue = $0 }
        )
    }

    private func saveDraft(original: Idea) {
        guard var draft else { return }
        draft.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !draft.title.isEmpty else {
            error = "El titulo no puede quedar vacio."
            return
        }

        var updated = original
        let now = Date()
        let statusChanged = updated.status != draft.status
        updated.title = draft.title
        updated.category = draft.category
        updated.link = normalizeOptionalLink(draft.link)
        updated.dateType = draft.dateType
        updated.dateStart = draft.dateType == .single || draft.dateType == .range ? draft.dateStart : nil
        updated.dateEnd = draft.dateType == .range ? draft.dateEnd : nil
        updated.flexibleNote = draft.dateType == .flexible ? nilIfEmpty(draft.flexibleNote) : nil
        updated.locationName = nilIfEmpty(draft.locationName)
        updated.idealConditions = draft.idealConditions
        updated.notes = nilIfEmpty(draft.notes)

        if statusChanged {
            updated.status = draft.status
            if draft.status == .done || draft.status == .repeatable {
                updated.completedAt = now
                updated.lastRepeatedAt = draft.status == .repeatable ? now : nil
            }
            if draft.status == .discarded {
                updated.discardedReason = .manual
            }
        }

        store.updateIdea(updated)
        self.draft = nil
        error = ""
        isEditing = false
    }

    private func nilIfEmpty(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func formatDate(_ date: Date) -> String {
        date.formatted(.dateTime.locale(Locale(identifier: "es")).day().month().year())
    }

    private func statusColor(_ status: IdeaStatus) -> Color {
        switch status {
        case .pending: .secondary
        case .done: .green
        case .repeatable: .orange
        case .discarded: .gray
        }
    }
}

private struct IdeaDraft {
    var title: String
    var category: IdeaCategory
    var status: IdeaStatus
    var link: String
    var dateType: IdeaDateType
    var dateStart: Date?
    var dateEnd: Date?
    var flexibleNote: String
    var locationName: String
    var idealConditions: [IdealCondition]
    var notes: String

    init(idea: Idea) {
        title = idea.title
        category = idea.category
        status = idea.status
        link = idea.link ?? ""
        dateType = idea.dateType
        dateStart = idea.dateStart
        dateEnd = idea.dateEnd
        flexibleNote = idea.flexibleNote ?? ""
        locationName = idea.locationName ?? ""
        idealConditions = idea.idealConditions
        notes = idea.notes ?? ""
    }
}

private struct DetailRow<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.headline.weight(.black))
            content
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
    }
}

private extension DetailRow where Content == Text {
    init(label: String, value: String) {
        self.label = label
        self.content = Text(value)
    }
}

private struct StatusActionButton: View {
    let systemName: String
    let active: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2.weight(.bold))
                .foregroundStyle(active ? Color.white : tint)
                .frame(width: 56, height: 56)
                .background(active ? tint : tint.opacity(0.12), in: Circle())
        }
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content

    var body: some View {
        WrappingLayout(horizontalSpacing: 8, verticalSpacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct WrappingLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .greatestFiniteMagnitude
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var measuredWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextX = currentX == 0 ? size.width : currentX + horizontalSpacing + size.width

            if currentX > 0 && nextX > maxWidth {
                currentY += lineHeight + verticalSpacing
                currentX = size.width
                lineHeight = size.height
            } else {
                currentX = nextX
                lineHeight = max(lineHeight, size.height)
            }

            measuredWidth = max(measuredWidth, currentX)
        }

        return CGSize(width: proposal.width ?? measuredWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextX = currentX == bounds.minX ? currentX + size.width : currentX + horizontalSpacing + size.width

            if currentX > bounds.minX && nextX > bounds.maxX {
                currentY += lineHeight + verticalSpacing
                currentX = bounds.minX
                lineHeight = 0
            } else if currentX > bounds.minX {
                currentX += horizontalSpacing
            }

            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width
            lineHeight = max(lineHeight, size.height)
        }
    }
}
