import Foundation
import Combine

final class AnalyticsViewModel: ObservableObject {
    let dataService: DataServiceProtocol

    @Published var selectedPeriod: String = "Ce mois"
    private var cancellables = Set<AnyCancellable>()

    let periods: [String] = [
        "Ce mois", "Ce trimestre", "Cette ann\u{00E9}e", "Mois dernier", "12 derniers mois"
    ]

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        if let ds = dataService as? DataService {
            ds.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }

    // MARK: - Computed from live data

    var properties: [Property] { dataService.properties }
    var mandates: [Mandate] { dataService.mandates }
    var visits: [Visit] { dataService.visits }
    var calls: [PhoneCall] { dataService.phoneCalls }

    var ventesCount: Int { properties.filter { $0.status == .sold }.count }
    var caFacture: Double { properties.compactMap(\.salePrice).reduce(0, +) }
    var prixMoyen: Double {
        let sold = properties.filter { $0.status == .sold }
        guard !sold.isEmpty else { return 0 }
        return caFacture / Double(sold.count)
    }
    var commission: Double { properties.compactMap(\.saleCommissionAmount).reduce(0, +) }
    var biensActifs: Int { properties.filter { $0.status == .available || $0.status == .underOffer }.count }
    var visitsCount: Int { visits.count }
    var mandatsSignes: Int { mandates.filter { $0.status == .complete || $0.status == .inProgress }.count }
    var tauxConversion: Double {
        guard !calls.isEmpty else { return 0 }
        return Double(ventesCount) / Double(calls.count) * 100
    }

    // Funnel
    var funnelAppels: Int { calls.count }
    var funnelPrisesEnCompte: Int { mandates.count }
    var funnelMandats: Int { mandatsSignes }
    var funnelVentes: Int { ventesCount }

    // Net income calculator
    var grossCommission: Double { commission }
    var socialCharges: Double { grossCommission * 0.2065 }
    var taxEstimate: Double { (grossCommission - socialCharges) * 0.45 }
    var netEstimate: Double { grossCommission - socialCharges - taxEstimate }

    // Monthly performance (mock)
    struct MonthPerformance: Identifiable {
        let id = UUID()
        let month: String
        let ventes: Int
        let ca: Double
        let mandats: Int
    }

    var monthlyPerformance: [MonthPerformance] {
        [
            MonthPerformance(month: "Janvier", ventes: 0, ca: 0, mandats: 2),
            MonthPerformance(month: "F\u{00E9}vrier", ventes: 0, ca: 0, mandats: 3),
            MonthPerformance(month: "Mars", ventes: ventesCount, ca: caFacture, mandats: mandatsSignes)
        ]
    }
}
