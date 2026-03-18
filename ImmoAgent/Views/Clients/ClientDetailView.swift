import SwiftUI

struct ClientDetailView: View {
    @State private var client: Client
    let dataService: DataServiceProtocol
    @Environment(AppCoordinator.self) private var coordinator
    @State private var isEditing = false
    @State private var newInterest = ""

    init(client: Client, dataService: DataServiceProtocol) {
        _client = State(initialValue: client)
        self.dataService = dataService
    }

    private var linkedProperties: [Property] {
        dataService.properties.filter { client.propertyIds.contains($0.id) }
    }

    private var clientVisits: [Visit] {
        dataService.visits.filter { $0.clientId == client.id }
            .sorted { $0.date > $1.date }
    }

    private var clientCalls: [PhoneCall] {
        dataService.phoneCalls.filter {
            $0.contactName.lowercased().contains(client.lastName.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack(spacing: 12) {
                Button {
                    coordinator.dismissDetail()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Clients")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Spacer()

                if isEditing {
                    Button("Annuler") {
                        isEditing = false
                    }
                    .buttonStyle(.bordered)

                    Button("Enregistrer") {
                        dataService.updateClient(client)
                        isEditing = false
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        isEditing = true
                    } label: {
                        Label("Modifier", systemImage: "pencil")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    headerSection
                    contactSection

                    Divider()

                    HStack(alignment: .top, spacing: 24) {
                        VStack(alignment: .leading, spacing: 20) {
                            linkedPropertiesSection
                            interestsSection
                            searchCriteriaSection
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 20) {
                            timelineSection
                            notesSection
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(28)
            }
        }
        .background(Color(.windowBackgroundColor))
        .onAppear {
            if coordinator.openDetailInEditMode {
                isEditing = true
                coordinator.openDetailInEditMode = false
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [colorForStatus(client.status), colorForStatus(client.status).opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                Text(client.initials)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        TextField("Pr\u{00E9}nom", text: $client.firstName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Nom", text: $client.lastName)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack(spacing: 12) {
                        Picker("Statut", selection: $client.status) {
                            ForEach(ClientStatus.allCases, id: \.self) { s in
                                Text(s.label).tag(s)
                            }
                        }
                        .frame(width: 150)

                        Picker("Source", selection: $client.source) {
                            ForEach(ClientSource.allCases, id: \.self) { s in
                                Text(s.label).tag(s)
                            }
                        }
                        .frame(width: 180)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text(client.fullName)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        BadgeView(text: client.source.label, variant: .info)
                        BadgeView.forClientStatus(client.status)
                        if client.budget > 0 {
                            Label(CurrencyFormatter.format(client.budget), systemImage: "eurosign.circle")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }

            Spacer()
        }
    }

    // MARK: - Contact

    private var contactSection: some View {
        Group {
            if isEditing {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.blue)
                        TextField("T\u{00E9}l\u{00E9}phone", text: $client.phone)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.blue)
                        TextField("Email", text: $client.email)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .foregroundStyle(.blue)
                        TextField("Budget", value: $client.budget, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                    }
                }
            } else {
                HStack(spacing: 12) {
                    if !client.phone.isEmpty {
                        Button {
                            if let url = URL(string: "tel:\(client.phone)") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Label(client.phone, systemImage: "phone.fill")
                        }
                        .buttonStyle(.bordered)
                    }

                    if !client.email.isEmpty {
                        Button {
                            if let url = URL(string: "mailto:\(client.email)") {
                                NSWorkspace.shared.open(url)
                            }
                        } label: {
                            Label(client.email, systemImage: "envelope.fill")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    // MARK: - Search Criteria

    private var searchCriteriaSection: some View {
        sectionCard(title: "CRIT\u{00C8}RES DE RECHERCHE", icon: "magnifyingglass") {
            if isEditing {
                TextEditor(text: $client.searchCriteria)
                    .frame(minHeight: 60)
                    .font(.body)
                    .scrollContentBackground(.hidden)
            } else {
                Text(client.searchCriteria.isEmpty ? "Aucun crit\u{00E8}re" : client.searchCriteria)
                    .font(.body)
                    .foregroundStyle(client.searchCriteria.isEmpty ? .secondary : .primary)
            }
        }
    }

    // MARK: - Linked Properties

    private var linkedPropertiesSection: some View {
        sectionCard(title: "BIENS LI\u{00C9}S", icon: "building.2.fill") {
            if linkedProperties.isEmpty {
                Text("Aucun bien li\u{00E9}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                VStack(spacing: 8) {
                    ForEach(linkedProperties) { property in
                        Button {
                            coordinator.showPropertyDetail(property.id)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(property.status == .sold ? Color.green.opacity(0.12) : Color.blue.opacity(0.08))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: iconForType(property.type))
                                        .font(.subheadline)
                                        .foregroundStyle(property.status == .sold ? .green : .blue)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(property.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    Text("\(property.fullAddress) \u{2022} \(CurrencyFormatter.format(property.price))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                BadgeView.forPropertyStatus(property.status)

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            .padding(10)
                            .background(Color(.controlBackgroundColor).opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Interests

    private var interestsSection: some View {
        sectionCard(title: "CENTRES D\u{2019}INT\u{00C9}R\u{00CA}T & PR\u{00C9}F\u{00C9}RENCES", icon: "heart.text.square") {
            VStack(alignment: .leading, spacing: 8) {
                if !isEditing {
                    Text("Sujets \u{00E0} aborder lors des \u{00E9}changes :")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if client.interests.isEmpty && !isEditing {
                    Text("Aucune pr\u{00E9}f\u{00E9}rence enregistr\u{00E9}e")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    FlowLayout(spacing: 6) {
                        ForEach(client.interests, id: \.self) { interest in
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.yellow)
                                Text(interest)
                                    .font(.caption)

                                if isEditing {
                                    Button {
                                        client.interests.removeAll { $0 == interest }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.08))
                            .clipShape(Capsule())
                        }
                    }
                }

                if isEditing {
                    HStack(spacing: 8) {
                        TextField("Ajouter un int\u{00E9}r\u{00EA}t...", text: $newInterest)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { addInterest() }
                        Button("Ajouter") { addInterest() }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .disabled(newInterest.isEmpty)
                    }
                }
            }
        }
    }

    private func addInterest() {
        let trimmed = newInterest.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        client.interests.append(trimmed)
        newInterest = ""
    }

    // MARK: - Notes

    private var notesSection: some View {
        sectionCard(title: "NOTES", icon: "note.text") {
            if isEditing {
                TextEditor(text: $client.notes)
                    .frame(minHeight: 80)
                    .font(.body)
                    .scrollContentBackground(.hidden)
            } else if client.notes.isEmpty {
                Text("Aucune note")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text(client.notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        sectionCard(title: "HISTORIQUE DES \u{00C9}V\u{00C9}NEMENTS", icon: "clock.arrow.circlepath") {
            let events = buildTimeline()

            if events.isEmpty {
                Text("Aucun \u{00E9}v\u{00E9}nement enregistr\u{00E9}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(event.color)
                                    .frame(width: 10, height: 10)
                                    .padding(.top, 4)

                                if index < events.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 2)
                                        .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(width: 10)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: event.icon)
                                        .font(.caption)
                                        .foregroundStyle(event.color)
                                    Text(event.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(event.date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if !event.subtitle.isEmpty {
                                    Text(event.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Timeline Builder

    private struct TimelineEvent {
        let icon: String
        let title: String
        let subtitle: String
        let date: String
        let color: Color
        let sortDate: String
    }

    private func buildTimeline() -> [TimelineEvent] {
        var events: [TimelineEvent] = []

        for visit in clientVisits {
            let statusIcon: String
            let color: Color
            switch visit.status {
            case .scheduled: statusIcon = "calendar"; color = .blue
            case .completed: statusIcon = "checkmark.circle.fill"; color = .green
            case .cancelled: statusIcon = "xmark.circle.fill"; color = .red
            case .noShow: statusIcon = "person.fill.xmark"; color = .orange
            }
            events.append(TimelineEvent(
                icon: statusIcon,
                title: "Visite: \(visit.propertyTitle)",
                subtitle: visit.notes,
                date: "\(visit.date) \u{00E0} \(visit.time)",
                color: color,
                sortDate: visit.date
            ))
        }

        for call in clientCalls {
            events.append(TimelineEvent(
                icon: "phone.fill",
                title: "Appel: \(call.reason)",
                subtitle: call.done ? "Effectu\u{00E9}" : "En attente",
                date: call.time ?? "",
                color: call.done ? .green : .orange,
                sortDate: "2026-03-18"
            ))
        }

        events.append(TimelineEvent(
            icon: "person.badge.plus",
            title: "Client cr\u{00E9}\u{00E9}",
            subtitle: "Source: \(client.source.label)",
            date: client.createdAt,
            color: .cyan,
            sortDate: client.createdAt
        ))

        return events.sorted { $0.sortDate > $1.sortDate }
    }

    // MARK: - Helpers

    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func colorForStatus(_ status: ClientStatus) -> Color {
        switch status {
        case .new: .cyan
        case .contacted: .blue
        case .visiting: .orange
        case .negotiating: .purple
        case .closed: .green
        }
    }

    private func iconForType(_ type: PropertyType) -> String {
        switch type {
        case .house: "house.fill"
        case .apartment: "building.fill"
        case .villa: "house.lodge.fill"
        case .land: "map.fill"
        case .commercial: "storefront.fill"
        }
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}

#Preview {
    ClientDetailView(client: DataService.demoClients[0], dataService: DataService())
        .environment(AppCoordinator())
        .frame(width: 1000, height: 800)
}
