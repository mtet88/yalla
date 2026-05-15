import SwiftUI

struct IdeaDetailView: View {
    let store: IdeaStore
    let ideaID: Idea.ID

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
    @State private var isEditing = false
    @State private var draft: IdeaDraft?
    @State private var showingDelete = false
    @State private var error = ""
    @State private var activeDateEditor: DateEditorMode?

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
        .sheet(item: $activeDateEditor) { mode in
            dateEditorSheet(mode: mode)
                .presentationDetents([mode.detent])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.appBackground)
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
                if let link = idea.link, !link.isEmpty {
                    DetailRow(label: "Link") {
                        Button(link) {
                            if let url = URL(string: link) { openURL(url) }
                        }
                        .foregroundStyle(.blue)
                    }
                }

                if let dateSummary = idea.dateSummary(locale: locale) {
                    DetailRow(label: "Fecha", value: dateSummary)
                } else {
                    DetailRow(label: "Fecha", localizedValue: "Sin fecha")
                }

                if let locationName = idea.locationName, !locationName.isEmpty {
                    DetailRow(label: "Ubicacion", value: locationName)
                } else {
                    DetailRow(label: "Ubicacion", localizedValue: "Sin ubicacion todavia")
                }

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

                if let notes = idea.notes, !notes.isEmpty {
                    DetailRow(label: "Notas", value: notes)
                } else {
                    DetailRow(label: "Notas", localizedValue: "Sin notas todavia")
                }

                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Creada", value: formatDate(idea.createdAt))
                    DetailRow(label: "Ultima actualizacion", value: formatDate(idea.updatedAt))
                    if let lastSuggestedAt = idea.lastSuggestedAt {
                        DetailRow(label: "Ultima vez sugerida", value: formatDate(lastSuggestedAt))
                    } else {
                        DetailRow(label: "Ultima vez sugerida", localizedValue: "Todavia no")
                    }
                    if let completedAt = idea.completedAt {
                        DetailRow(label: "Hecha", value: formatDate(completedAt))
                    } else {
                        DetailRow(label: "Hecha", localizedValue: "Todavia no")
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.softBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }

            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    StatusActionButton(systemName: "checkmark", active: idea.status == .done, tint: .green) {
                        toggleStatus(for: idea, selectedStatus: .done)
                    }
                    StatusActionButton(systemName: "arrow.clockwise", active: idea.status == .repeatable, tint: .orange) {
                        toggleStatus(for: idea, selectedStatus: .repeatable)
                    }
                    StatusActionButton(systemName: "xmark", active: idea.status == .discarded, tint: .gray) {
                        toggleStatus(for: idea, selectedStatus: .discarded)
                    }
                }

                Text(idea.status.label)
                    .font(.caption.weight(.black))
                    .textCase(.uppercase)
                    .tracking(2)
                    .foregroundStyle(statusColor(idea.status))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(22)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        .padding(20)
    }

    private func toggleStatus(for idea: Idea, selectedStatus: IdeaStatus) {
        let nextStatus: IdeaStatus = idea.status == selectedStatus ? .pending : selectedStatus
        store.updateStatus(for: idea, status: nextStatus)
    }

    private func editView(idea: Idea) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            let draftBinding = Binding(
                get: { draft ?? IdeaDraft(idea: idea) },
                set: { draft = $0 }
            )

            HStack {
                Text("Tipo de idea")
                    .font(.headline)
                Spacer()
                Picker("Tipo de idea", selection: draftBinding.category) {
                    ForEach(IdeaCategory.allCases) { category in
                        Text(category.label).tag(category)
                    }
                }
            }

            HStack {
                Text("Estado")
                    .font(.headline)
                Spacer()
                Picker("Estado", selection: draftBinding.status) {
                    ForEach(IdeaStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
            }

            dateSelectionRow(draftBinding: draftBinding)

            VStack(alignment: .leading, spacing: 8) {
                Text("Titulo").font(.headline)
                TextField("Titulo", text: draftBinding.title)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Link").font(.headline)
                TextField("https://...", text: draftBinding.link)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .textFieldStyle(.roundedBorder)
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

    @ViewBuilder
    private func dateSelectionRow(draftBinding: Binding<IdeaDraft>) -> some View {
        let currentDraft = draftBinding.wrappedValue

        HStack {
            Text("Fecha")
                .font(.headline)
            Spacer()

            if currentDraft.dateType == .single, let date = currentDraft.dateStart {
                selectedDateLabel(formatCompactDate(date)) {
                    clearDate(draftBinding: draftBinding)
                }
            } else if currentDraft.dateType == .range, let start = currentDraft.dateStart, let end = currentDraft.dateEnd {
                selectedDateLabel("\(formatCompactDate(start)) - \(formatCompactDate(end))") {
                    clearDate(draftBinding: draftBinding)
                }
            } else {
                Picker("Fecha", selection: dateTypeSelection(draftBinding)) {
                    ForEach(IdeaDateType.editableCases) { type in
                        Text(type.label).tag(type)
                    }
                }
            }
        }
    }

    private func selectedDateLabel(_ text: String, clear: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.subheadline)
            Button(action: clear) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.black))
                    .foregroundStyle(Color.yallaPrimary)
                    .frame(width: 24, height: 24)
            }
            .accessibilityLabel("Quitar fecha")
        }
    }

    private func dateTypeSelection(_ draftBinding: Binding<IdeaDraft>) -> Binding<IdeaDateType> {
        Binding<IdeaDateType>(
            get: { draftBinding.wrappedValue.dateType },
            set: { nextType in
                switch nextType {
                case .none:
                    clearDate(draftBinding: draftBinding)
                case .single:
                    activeDateEditor = .single
                case .range:
                    activeDateEditor = .range
                }
            }
        )
    }

    private func clearDate(draftBinding: Binding<IdeaDraft>) {
        var next = draftBinding.wrappedValue
        next.dateType = .none
        next.dateStart = nil
        next.dateEnd = nil
        draftBinding.wrappedValue = next
    }

    private func dateEditorSheet(mode: DateEditorMode) -> some View {
        NavigationStack {
            switch mode {
            case .single:
                SingleDatePickerSheet(initialDate: draft?.dateStart ?? Date()) { selectedDate in
                    guard var draft else { return }
                    draft.dateType = .single
                    draft.dateStart = selectedDate
                    draft.dateEnd = nil
                    self.draft = draft
                    activeDateEditor = nil
                }
            case .range:
                DateRangePickerSheet(initialStart: draft?.dateStart ?? Date(), initialEnd: draft?.dateEnd ?? draft?.dateStart ?? Date()) { startDate, endDate in
                    guard var draft else { return }
                    draft.dateType = .range
                    draft.dateStart = startDate
                    draft.dateEnd = max(startDate, endDate)
                    self.draft = draft
                    activeDateEditor = nil
                }
            }
        }
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
        date.formatted(.dateTime.locale(locale).day().month().year())
    }

    private func formatCompactDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
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
    var locationName: String
    var idealConditions: [IdealCondition]
    var notes: String

    init(idea: Idea) {
        title = idea.title
        category = idea.category
        status = idea.status
        link = idea.link ?? ""
        dateStart = idea.dateStart
        dateEnd = idea.dateEnd
        if idea.dateType == .single, idea.dateStart != nil {
            dateType = .single
        } else if idea.dateType == .range, idea.dateStart != nil, idea.dateEnd != nil {
            dateType = .range
        } else {
            dateType = .none
        }
        locationName = idea.locationName ?? ""
        idealConditions = idea.idealConditions
        notes = idea.notes ?? ""
    }
}

private enum DateEditorMode: Identifiable {
    case single
    case range

    var id: String {
        switch self {
        case .single: "single"
        case .range: "range"
        }
    }

    var detent: PresentationDetent {
        switch self {
        case .single: .height(500)
        case .range: .height(260)
        }
    }
}

private struct SingleDatePickerSheet: View {
    let onSave: (Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate: Date

    init(initialDate: Date, onSave: @escaping (Date) -> Void) {
        self.onSave = onSave
        _selectedDate = State(initialValue: initialDate)
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                DatePicker("Fecha", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .navigationTitle("Fecha especifica")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ConfirmButton { onSave(selectedDate) }
            }
        }
    }
}

private struct DateRangePickerSheet: View {
    let onSave: (Date, Date) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var startDate: Date
    @State private var endDate: Date

    init(initialStart: Date, initialEnd: Date, onSave: @escaping (Date, Date) -> Void) {
        self.onSave = onSave
        _startDate = State(initialValue: initialStart)
        _endDate = State(initialValue: max(initialStart, initialEnd))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                DatePicker("Empieza", selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .onChange(of: startDate) { _, newStartDate in
                        if endDate < newStartDate {
                            endDate = newStartDate
                        }
                    }

                DatePicker("Termina", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            .padding(24)
        }
        .navigationTitle("Rango de fechas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CloseButton { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ConfirmButton { onSave(startDate, endDate) }
            }
        }
    }
}

private struct DetailRow<Content: View>: View {
    let label: LocalizedStringKey
    let content: Content

    init(label: LocalizedStringKey, @ViewBuilder content: () -> Content) {
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
    init(label: LocalizedStringKey, value: String) {
        self.label = label
        self.content = Text(value)
    }

    init(label: LocalizedStringKey, localizedValue: LocalizedStringKey) {
        self.label = label
        self.content = Text(localizedValue)
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
