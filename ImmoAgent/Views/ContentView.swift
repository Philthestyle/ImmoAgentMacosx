import SwiftUI

struct ContentView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        @Bindable var coord = coordinator

        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 280)
        } detail: {
            detailContent
        }
    }

    // MARK: - Sidebar

    @ViewBuilder
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // Logo
            HStack(spacing: 8) {
                Image(systemName: "building.columns.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("ImmoAgent")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)

            Divider()
                .padding(.horizontal, 16)

            // Navigation items
            List(selection: Binding(
                get: { coordinator.selectedDestination },
                set: {
                    coordinator.selectedDestination = $0
                    coordinator.dismissDetail()
                }
            )) {
                Section {
                    ForEach(AppDestination.allCases.filter { $0 != .settings }) { dest in
                        Label(dest.rawValue, systemImage: dest.icon)
                            .tag(dest)
                    }
                }

                Section {
                    Label(AppDestination.settings.rawValue, systemImage: AppDestination.settings.icon)
                        .tag(AppDestination.settings)
                }
            }
            .listStyle(.sidebar)

            Spacer()

            // Demo/Real toggle
            demoToggleButton
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 16)

            // Profile
            profileSection
                .padding(16)
        }
    }

    private var dataService: DataServiceProtocol {
        container.dataService
    }

    private var demoToggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                dataService.toggleDemo()
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(dataService.isDemo ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                Text(dataService.isDemo ? "Passer en mode r\u{00E9}el" : "Passer en mode Demo")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                (dataService.isDemo ? Color.orange : Color.green).opacity(0.12)
            )
            .foregroundStyle(dataService.isDemo ? .orange : .green)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var profileSection: some View {
        let profile = dataService.profile
        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                Text(profile.initials)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(profile.firstName) \(profile.lastName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(profile.company)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailContent: some View {
        if let detail = coordinator.detailItem {
            switch detail {
            case .mandate(let id):
                if let mandate = dataService.mandates.first(where: { $0.id == id }) {
                    MandateDetailView(mandate: mandate, dataService: dataService)
                }
            case .property(let id):
                if let property = dataService.properties.first(where: { $0.id == id }) {
                    PropertyDetailView(property: property)
                }
            case .client(let id):
                if let client = dataService.clients.first(where: { $0.id == id }) {
                    ClientDetailView(client: client, dataService: dataService)
                }
            }
        } else {
            switch coordinator.selectedDestination {
            case .dashboard:
                DashboardView(dataService: dataService)
            case .properties:
                PropertiesView(dataService: dataService)
            case .clients:
                ClientsView(dataService: dataService)
            case .mandates:
                MandatesView(dataService: dataService)
            case .agenda:
                AgendaView(dataService: dataService)
            case .analytics:
                AnalyticsView(dataService: dataService)
            case .settings:
                SettingsView(dataService: dataService)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DependencyContainer())
        .environment(AppCoordinator())
        .frame(width: 1200, height: 800)
}
