import Foundation

enum ClientStatus: String, Codable, CaseIterable {
    case new, contacted, visiting, negotiating, closed
    var label: String {
        switch self {
        case .new: "Nouveau"
        case .contacted: "Contacté"
        case .visiting: "En visite"
        case .negotiating: "Négociation"
        case .closed: "Conclu"
        }
    }
}

enum ClientSource: String, Codable, CaseIterable {
    case website, referral, social, portal, walkIn = "walk_in"
    var label: String {
        switch self {
        case .website: "Site web"
        case .referral: "Recommandation"
        case .social: "Réseaux sociaux"
        case .portal: "Portail"
        case .walkIn: "Passage"
        }
    }
}

struct Client: Identifiable, Codable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var budget: Double
    var status: ClientStatus
    var source: ClientSource
    var searchCriteria: String
    var createdAt: String
    var lastContact: String
    var notes: String
    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))" }
}
