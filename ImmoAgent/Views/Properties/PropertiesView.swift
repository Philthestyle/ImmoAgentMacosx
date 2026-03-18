import SwiftUI

struct PropertiesView: View {
    let dataService: DataServiceProtocol
    @StateObject private var viewModel: PropertiesViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        _viewModel = StateObject(wrappedValue: PropertiesViewModel(dataService: dataService))
    }

    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 360), spacing: 20)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Biens immobiliers")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(viewModel.filteredProperties.count) bien\(viewModel.filteredProperties.count > 1 ? "s" : "") sur \(viewModel.properties.count)")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // View mode toggle
                    Picker("Affichage", selection: $viewModel.viewMode) {
                        ForEach(PropertiesViewModel.ViewMode.allCases, id: \.self) { mode in
                            Image(systemName: mode.icon)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 80)

                    Button {
                        viewModel.addProperty()
                    } label: {
                        Label("Ajouter un bien", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                HStack(spacing: 12) {
                    // Search
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Rechercher un bien...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(10)
                    .background(Color(.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .frame(maxWidth: 320)

                    // Filter pills
                    ForEach(viewModel.filters, id: \.self) { filter in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedFilter = filter
                            }
                        } label: {
                            Text(filter)
                                .font(.subheadline)
                                .fontWeight(viewModel.selectedFilter == filter ? .semibold : .regular)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    viewModel.selectedFilter == filter
                                        ? Color.blue.opacity(0.15)
                                        : Color(.controlBackgroundColor)
                                )
                                .foregroundStyle(
                                    viewModel.selectedFilter == filter ? .blue : .primary
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()
                }
            }
            .padding(28)
            .padding(.bottom, 0)

            // Content
            if viewModel.filteredProperties.isEmpty {
                EmptyStateView(
                    icon: "building.2",
                    title: "Aucun bien trouv\u{00E9}",
                    description: "Modifiez vos filtres ou ajoutez un nouveau bien.",
                    actionTitle: "Ajouter un bien"
                ) {
                    viewModel.addProperty()
                }
            } else {
                switch viewModel.viewMode {
                case .cards:
                    cardsView
                case .list:
                    listView
                }
            }
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Cards View

    private var cardsView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.filteredProperties) { property in
                    PropertyCardView(property: property)
                        .onTapGesture {
                            coordinator.showPropertyDetail(property.id)
                        }
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }

    // MARK: - List View

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                // Table header
                HStack(spacing: 0) {
                    Text("Bien")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Type")
                        .frame(width: 100, alignment: .leading)
                    Text("Prix")
                        .frame(width: 140, alignment: .trailing)
                    Text("Surface")
                        .frame(width: 80, alignment: .trailing)
                    Text("Ch.")
                        .frame(width: 50, alignment: .trailing)
                    Text("Statut")
                        .frame(width: 110, alignment: .center)
                    Text("Propri\u{00E9}taire")
                        .frame(width: 140, alignment: .leading)
                }
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.controlBackgroundColor).opacity(0.5))

                Divider()

                ForEach(viewModel.filteredProperties) { property in
                    propertyRow(property)
                        .onTapGesture {
                            coordinator.showPropertyDetail(property.id)
                        }
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
    }

    private func propertyRow(_ property: Property) -> some View {
        HStack(spacing: 0) {
            // Property info
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(property.status == .sold
                              ? Color.green.opacity(0.12)
                              : Color.blue.opacity(0.08))
                        .frame(width: 40, height: 40)
                    Image(systemName: iconForType(property.type))
                        .font(.subheadline)
                        .foregroundStyle(property.status == .sold ? .green : .blue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(property.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text(property.fullAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Type
            Text(property.type.label)
                .font(.caption)
                .frame(width: 100, alignment: .leading)

            // Price
            Text(CurrencyFormatter.format(property.price))
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 140, alignment: .trailing)

            // Surface
            Text("\(Int(property.surface)) m\u{00B2}")
                .font(.subheadline)
                .frame(width: 80, alignment: .trailing)

            // Bedrooms
            Text(property.bedrooms > 0 ? "\(property.bedrooms)" : "-")
                .font(.subheadline)
                .frame(width: 50, alignment: .trailing)

            // Status
            BadgeView.forPropertyStatus(property.status)
                .frame(width: 110, alignment: .center)

            // Owner
            Text(property.ownerName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 140, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.vertical, 2)
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

#Preview {
    PropertiesView(dataService: DataService())
        .frame(width: 1000, height: 800)
}
