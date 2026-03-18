import Foundation

enum MandateType: String, Codable, CaseIterable {
    case exclusive, coExclusive = "co-exclusive", simple
    var label: String {
        switch self {
        case .exclusive: "Exclusif"
        case .coExclusive: "Co-exclusif"
        case .simple: "Simple"
        }
    }
}

enum MandateStatus: String, Codable, CaseIterable {
    case draft, inProgress = "in_progress", complete, expired, cancelled
    var label: String {
        switch self {
        case .draft: "Brouillon"
        case .inProgress: "En cours"
        case .complete: "Complet"
        case .expired: "Expiré"
        case .cancelled: "Annulé"
        }
    }
}

struct MandateDocument: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var category: String
    var required: Bool
    var provided: Bool
    var fileName: String?
    var filePath: String?
}

struct Mandate: Identifiable, Codable {
    let id: String
    var propertyId: String
    var propertyTitle: String
    var ownerName: String
    var type: MandateType
    var startDate: String
    var endDate: String
    var status: MandateStatus
    var commissionPercent: Double
    var askingPrice: Double
    var documents: [MandateDocument]

    var providedCount: Int { documents.filter(\.provided).count }
    var requiredMissing: Int { documents.filter { $0.required && !$0.provided }.count }
    var completionPercent: Int {
        guard !documents.isEmpty else { return 0 }
        return Int(Double(providedCount) / Double(documents.count) * 100)
    }
}
