import Foundation

enum VisitStatus: String, Codable, CaseIterable {
    case scheduled, completed, cancelled, noShow = "no_show"
    var label: String {
        switch self {
        case .scheduled: "Planifiée"
        case .completed: "Effectuée"
        case .cancelled: "Annulée"
        case .noShow: "Absent"
        }
    }
}

struct Visit: Identifiable, Codable {
    let id: String
    var propertyId: String
    var propertyTitle: String
    var clientId: String
    var clientName: String
    var date: String
    var time: String
    var status: VisitStatus
    var notes: String
    var agent: String
}
