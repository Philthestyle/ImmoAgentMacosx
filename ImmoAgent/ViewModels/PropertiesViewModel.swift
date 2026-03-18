import Foundation
import Combine

final class PropertiesViewModel: ObservableObject {
    let dataService: DataServiceProtocol

    @Published var selectedFilter: String = "Tous"
    @Published var searchText: String = ""
    @Published var selectedProperty: Property?
    @Published var viewMode: ViewMode = .cards

    enum ViewMode: String, CaseIterable {
        case cards, list
        var icon: String {
            switch self {
            case .cards: "square.grid.2x2"
            case .list: "list.bullet"
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()

    let filters = ["Tous", "Disponible", "Sous offre", "Vendu", "Lou\u{00E9}"]

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        if let ds = dataService as? DataService {
            ds.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }

    var properties: [Property] { dataService.properties }

    var filteredProperties: [Property] {
        var result = properties

        if selectedFilter != "Tous" {
            result = result.filter { $0.status.label == selectedFilter }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.fullAddress.lowercased().contains(query) ||
                $0.city.lowercased().contains(query) ||
                $0.ownerName.lowercased().contains(query)
            }
        }

        return result.sorted { a, b in
            if (a.status == .sold) != (b.status == .sold) {
                return a.status != .sold
            }
            return a.createdAt > b.createdAt
        }
    }

    func addProperty() {
        let newProp = Property(
            id: UUID().uuidString, title: "Nouveau bien", street: "",
            streetNumber: "", postalCode: "", city: "", country: "Belgique",
            price: 0, surface: 0, rooms: 0, bedrooms: 0, bathrooms: 0,
            type: .apartment, status: .available, images: [],
            description: "", createdAt: ISO8601DateFormatter().string(from: Date()),
            ownerName: "", ownerPhone: "", ownerEmail: ""
        )
        dataService.addProperty(newProp)
        selectedProperty = newProp
    }
}
