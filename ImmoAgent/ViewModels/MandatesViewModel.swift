import Foundation
import Combine

final class MandatesViewModel: ObservableObject {
    let dataService: DataServiceProtocol

    @Published var selectedMandate: Mandate?
    @Published var filterStatus: String = "Tous"
    private var cancellables = Set<AnyCancellable>()

    let statusFilters = ["Tous", "En cours", "Complet", "Brouillon", "Expir\u{00E9}", "Annul\u{00E9}"]

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        if let ds = dataService as? DataService {
            ds.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }

    var mandates: [Mandate] { dataService.mandates }

    var filteredMandates: [Mandate] {
        guard filterStatus != "Tous" else { return mandates }
        return mandates.filter { $0.status.label == filterStatus }
    }

    var total: Int { mandates.count }

    var complete: Int {
        mandates.filter { $0.status == .complete }.count
    }

    var inProgress: Int {
        mandates.filter { $0.status == .inProgress }.count
    }

    var draft: Int {
        mandates.filter { $0.status == .draft }.count
    }
}
