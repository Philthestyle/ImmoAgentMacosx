import SwiftUI

struct ClientDetailView: View {
    let client: Client
    @Environment(AppCoordinator.self) private var coordinator

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

                BadgeView(text: client.source.label, variant: .info)
                BadgeView.forClientStatus(client.status)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
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

                        VStack(alignment: .leading, spacing: 6) {
                            Text(client.fullName)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            HStack(spacing: 8) {
                                BadgeView(text: client.source.label, variant: .info)
                                BadgeView.forClientStatus(client.status)
                            }
                        }

                        Spacer()
                    }

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

                    Divider()

                    // Info sections
                    HStack(alignment: .top, spacing: 20) {
                        // Left column
                        VStack(alignment: .leading, spacing: 20) {
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
                        }
                        .frame(maxWidth: .infinity)

                        // Right column
                        VStack(alignment: .leading, spacing: 20) {
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
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(28)
            }
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

    private func colorForStatus(_ status: ClientStatus) -> Color {
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
    ClientDetailView(client: DataService.demoClients[0])
        .environment(AppCoordinator())
        .frame(width: 900, height: 700)
}
