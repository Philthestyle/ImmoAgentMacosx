import SwiftUI

struct ClientsView: View {
    let dataService: DataServiceProtocol
    @StateObject private var viewModel: ClientsViewModel

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        _viewModel = StateObject(wrappedValue: ClientsViewModel(dataService: dataService))
    }

    var body: some View {
        HSplitView {
            // Left: Client list
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Clients")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button {
                        viewModel.addClient()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .padding(20)

                // Search
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Rechercher...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                }
                .padding(10)
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                Divider()

                // List
                List(viewModel.filteredClients, selection: $viewModel.selectedClient) { client in
                    clientRow(client)
                        .tag(client)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
            }
            .frame(minWidth: 320, idealWidth: 360, maxWidth: 420)
            .background(Color(.windowBackgroundColor))

            // Right: Detail
            if let client = viewModel.selectedClient {
                clientDetail(client)
            } else {
                EmptyStateView(
                    icon: "person.2",
                    title: "S\u{00E9}lectionnez un client",
                    description: "Choisissez un client dans la liste pour voir ses informations."
                )
            }
        }
    }

    // MARK: - Client Row

    private func clientRow(_ client: Client) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(colorForClientStatus(client.status).opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(client.initials)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(colorForClientStatus(client.status))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(client.fullName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    BadgeView.forClientStatus(client.status)
                }

                Text(client.searchCriteria)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Client Detail

    private func clientDetail(_ client: Client) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [colorForClientStatus(client.status), colorForClientStatus(client.status).opacity(0.6)],
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

                    VStack(alignment: .leading, spacing: 6) {
                        Text(client.fullName)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack(spacing: 8) {
                            BadgeView(text: client.source.label, variant: .info)
                            BadgeView.forClientStatus(client.status)
                        }
                    }

                    Spacer()
                }

                Divider()

                // Contact actions
                HStack(spacing: 12) {
                    Button {
                        if let url = URL(string: "tel:\(client.phone)") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label(client.phone, systemImage: "phone.fill")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        if let url = URL(string: "mailto:\(client.email)") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label(client.email, systemImage: "envelope.fill")
                    }
                    .buttonStyle(.bordered)
                }

                // Info sections
                detailSection(title: "CRIT\u{00C8}RES DE RECHERCHE", icon: "magnifyingglass") {
                    Text(client.searchCriteria)
                        .font(.body)
                }

                if client.budget > 0 {
                    detailSection(title: "BUDGET", icon: "eurosign.circle") {
                        Text(CurrencyFormatter.format(client.budget))
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                if !client.notes.isEmpty {
                    detailSection(title: "NOTES", icon: "note.text") {
                        Text(client.notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                detailSection(title: "INFORMATIONS", icon: "info.circle") {
                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(label: "Email", value: client.email)
                        infoRow(label: "T\u{00E9}l\u{00E9}phone", value: client.phone)
                        infoRow(label: "Source", value: client.source.label)
                        infoRow(label: "Statut", value: client.status.label)
                        infoRow(label: "Cr\u{00E9}\u{00E9} le", value: client.createdAt)
                        infoRow(label: "Dernier contact", value: client.lastContact)
                    }
                }
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Helpers

    private func detailSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.subheadline)
        }
    }

    private func colorForClientStatus(_ status: ClientStatus) -> Color {
        switch status {
        case .new: .cyan
        case .contacted: .blue
        case .visiting: .orange
        case .negotiating: .purple
        case .closed: .green
        }
    }
}

#Preview {
    ClientsView(dataService: DataService())
        .frame(width: 1000, height: 700)
}
