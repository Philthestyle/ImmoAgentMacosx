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

@Observable
final class AppCoordinator {
    var selectedDestination: AppDestination = .dashboard
}
