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
    var volumeVentes: Double { properties.compactMap(\.salePrice).reduce(0, +) }
    var caFacture: Double { properties.compactMap(\.saleCommissionAmount).reduce(0, +) }
    var prixMoyen: Double {
        let sold = properties.filter { $0.status == .sold }
        guard !sold.isEmpty else { return 0 }
        return volumeVentes / Double(sold.count)
    }
    var commission: Double { caFacture }
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

    // Stats aggregate
    struct Stats {
        let ventesCount: Int
        let formattedCA: String
        let formattedPrixMoyen: String
        let formattedCommission: String
        let biensActifs: Int
        let visitsCount: Int
        let mandatsSignes: Int
        let tauxConversion: Double
    }

    var stats: Stats {
        Stats(
            ventesCount: ventesCount,
            formattedCA: CurrencyFormatter.format(caFacture),
            formattedPrixMoyen: CurrencyFormatter.format(prixMoyen),
            formattedCommission: CurrencyFormatter.format(commission),
            biensActifs: biensActifs,
            visitsCount: visitsCount,
            mandatsSignes: mandatsSignes,
            tauxConversion: tauxConversion
        )
    }

    // Funnel aggregate
    struct Funnel {
        let appels: Int
        let prisesEnCompte: Int
        let mandats: Int
        let ventes: Int
    }

    var funnel: Funnel {
        Funnel(
            appels: funnelAppels,
            prisesEnCompte: funnelPrisesEnCompte,
            mandats: funnelMandats,
            ventes: funnelVentes
        )
    }

    // Formatter helper
    func formatted(_ value: Double) -> String {
        CurrencyFormatter.format(value)
    }

    // Sold properties detail
    struct SaleDetail: Identifiable {
        let id: String
        let title: String
        let salePrice: Double
        let commission: Double
        let netCommission: Double
    }

    var salesDetails: [SaleDetail] {
        properties.filter { $0.status == .sold }.map { prop in
            let comm = prop.saleCommissionAmount ?? 0
            let social = comm * 0.2065
            let tax = (comm - social) * 0.45
            let net = comm - social - tax
            return SaleDetail(
                id: prop.id,
                title: prop.title,
                salePrice: prop.salePrice ?? prop.price,
                commission: comm,
                netCommission: net
            )
        }
    }

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
            MonthPerformance(month: "Mars", ventes: ventesCount, ca: commission, mandats: mandatsSignes)
        ]
    }
}
