import Foundation
import Combine

final class ClientsViewModel: ObservableObject {
    let dataService: DataServiceProtocol

    @Published var selectedClient: Client?
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        if let ds = dataService as? DataService {
            ds.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }

    var clients: [Client] { dataService.clients }

    var filteredClients: [Client] {
        guard !searchText.isEmpty else { return clients }
        let query = searchText.lowercased()
        return clients.filter {
            $0.fullName.lowercased().contains(query) ||
            $0.email.lowercased().contains(query) ||
            $0.searchCriteria.lowercased().contains(query)
        }
    }

    func addClient() {
        let newClient = Client(
            id: UUID().uuidString, firstName: "Nouveau", lastName: "Client",
            email: "", phone: "", budget: 0,
            status: .new, source: .website,
            searchCriteria: "", createdAt: ISO8601DateFormatter().string(from: Date()),
            lastContact: ISO8601DateFormatter().string(from: Date()), notes: ""
        )
        dataService.addClient(newClient)
        selectedClient = newClient
    }
}
