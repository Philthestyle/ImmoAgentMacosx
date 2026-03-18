import SwiftUI

enum AppDestination: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case properties = "Biens"
    case clients = "Clients"
    case mandates = "Mandats"
    case agenda = "Agenda"
    case analytics = "Statistiques"
    case settings = "Param\u{00E8}tres"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: "square.grid.2x2"
        case .properties: "building.2"
        case .clients: "person.2"
        case .mandates: "doc.text.magnifyingglass"
        case .agenda: "calendar"
        case .analytics: "chart.bar"
        case .settings: "gear"
        }
    }
}

enum DetailItem: Equatable, Hashable {
    case mandate(String)   // mandate id
    case property(String)  // property id
    case client(String)    // client id
}

@Observable
final class AppCoordinator {
    var selectedDestination: AppDestination = .dashboard
    var detailItem: DetailItem?

    func showMandateDetail(_ mandateId: String) {
        detailItem = .mandate(mandateId)
    }

    func showPropertyDetail(_ propertyId: String) {
        detailItem = .property(propertyId)
    }

    func showClientDetail(_ clientId: String) {
        detailItem = .client(clientId)
    }

    func dismissDetail() {
        detailItem = nil
    }
}
