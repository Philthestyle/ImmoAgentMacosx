import SwiftUI

struct ClientsView: View {
    let dataService: DataServiceProtocol
    @StateObject private var viewModel: ClientsViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        _viewModel = StateObject(wrappedValue: ClientsViewModel(dataService: dataService))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clients")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("\(viewModel.filteredClients.count) client\(viewModel.filteredClients.count > 1 ? "s" : "")")
                        .foregroundStyle(.secondary)
                }

                Spacer()

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
                .frame(maxWidth: 280)

                Button {
                    viewModel.addClient()
                } label: {
                    Label("Nouveau client", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(28)

            Divider()

            // Client grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16)], spacing: 16) {
                    ForEach(viewModel.filteredClients) { client in
                        clientCard(client)
                            .onTapGesture {
                                coordinator.showClientDetail(client.id)
                            }
                            .contentShape(Rectangle())
                    }
                }
                .padding(28)
            }
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Client Card

    private func clientCard(_ client: Client) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(colorForClientStatus(client.status).opacity(0.15))
                        .frame(width: 44, height: 44)
                    Text(client.initials)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(colorForClientStatus(client.status))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(client.fullName)
                        .font(.headline)
                    Text(client.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                BadgeView.forClientStatus(client.status)
            }

            Text(client.searchCriteria)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                if client.budget > 0 {
                    Label(CurrencyFormatter.format(client.budget), systemImage: "eurosign.circle")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                Spacer()
                Label(client.lastContact, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
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
        .environment(AppCoordinator())
        .frame(width: 1000, height: 700)
}
