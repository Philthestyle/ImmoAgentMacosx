import SwiftUI

struct PropertiesView: View {
    let dataService: DataServiceProtocol
    @StateObject private var viewModel: PropertiesViewModel

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
                        Text("\(viewModel.properties.count) biens au total")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

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

            // Grid
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
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.filteredProperties) { property in
                            PropertyCardView(property: property)
                                .onTapGesture {
                                    viewModel.selectedProperty = property
                                }
                                .contentShape(Rectangle())
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
            }
        }
        .background(Color(.windowBackgroundColor))
        .sheet(item: $viewModel.selectedProperty) { property in
            PropertyDetailView(property: property)
                .frame(minWidth: 600, minHeight: 500)
        }
    }
}

#Preview {
    PropertiesView(dataService: DataService())
        .frame(width: 1000, height: 800)
}
