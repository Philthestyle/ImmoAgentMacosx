import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    let dataService: DataServiceProtocol

    @Published var selectedPeriod: String = "Ce mois"
    private var cancellables = Set<AnyCancellable>()

    let periods: [String] = [
        "Ce mois", "Ce trimestre", "Cette ann\u{00E9}e", "Mois dernier", "12 derniers mois"
    ]

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        // Observe changes from DataService if it's an ObservableObject
        if let ds = dataService as? DataService {
            ds.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }

    // MARK: - Computed from live data

    var properties: [Property] { dataService.properties }
    var clients: [Client] { dataService.clients }
    var phoneCalls: [PhoneCall] { dataService.phoneCalls }

    var ventesCount: Int {
        properties.filter { $0.status == .sold }.count
    }

    var caFacture: Double {
        properties.compactMap(\.salePrice).reduce(0, +)
    }

    var prixMoyen: Double {
        let sold = properties.filter { $0.status == .sold }
        guard !sold.isEmpty else { return 0 }
        return caFacture / Double(sold.count)
    }

    var commission: Double {
        properties.compactMap(\.saleCommissionAmount).reduce(0, +)
    }

    var biensActifs: Int {
        properties.filter { $0.status == .available || $0.status == .underOffer }.count
    }

    var netEstimate: Double {
        caFacture * 0.8
    }

    var pendingCalls: [PhoneCall] { phoneCalls.filter { !$0.done } }
    var doneCalls: [PhoneCall] { phoneCalls.filter { $0.done } }

    var scheduledCalls: [PhoneCall] {
        pendingCalls.filter { $0.time != nil }
            .sorted { ($0.time ?? "") < ($1.time ?? "") }
    }

    var unscheduledCalls: [PhoneCall] {
        pendingCalls.filter { $0.time == nil }
    }

    // Funnel data derived from actual counts
    var funnelAppels: Int { phoneCalls.count }
    var funnelPrisesEnCompte: Int { dataService.mandates.count }
    var funnelMandats: Int { dataService.mandates.filter { $0.status == .complete || $0.status == .inProgress }.count }
    var funnelVentes: Int { ventesCount }

    // MARK: - Actions

    func toggleCallDone(_ call: PhoneCall) {
        if let idx = dataService.phoneCalls.firstIndex(where: { $0.id == call.id }) {
            dataService.phoneCalls[idx].done.toggle()
        }
    }
}
