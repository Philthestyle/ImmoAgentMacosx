import Foundation

enum PropertyType: String, Codable, CaseIterable, Identifiable {
    case apartment = "apartment"
    case house = "house"
    case villa = "villa"
    case land = "land"
    case commercial = "commercial"

    var id: String { rawValue }
    var label: String {
        switch self {
        case .apartment: "Appartement"
        case .house: "Maison"
        case .villa: "Villa"
        case .land: "Terrain"
        case .commercial: "Commercial"
        }
    }
}

enum PropertyStatus: String, Codable, CaseIterable, Identifiable {
    case available, underOffer = "under_offer", sold, rented
    var id: String { rawValue }
    var label: String {
        switch self {
        case .available: "Disponible"
        case .underOffer: "Sous offre"
        case .sold: "Vendu"
        case .rented: "Loué"
        }
    }
}

struct Property: Identifiable, Codable {
    let id: String
    var title: String
    var street: String
    var streetNumber: String
    var postalCode: String
    var city: String
    var country: String
    var price: Double
    var surface: Double
    var rooms: Int
    var bedrooms: Int
    var bathrooms: Int
    var type: PropertyType
    var status: PropertyStatus
    var images: [String]
    var description: String
    var createdAt: String
    var ownerName: String
    var ownerPhone: String
    var ownerEmail: String
    var listingUrl: String?
    var mandateId: String?
    var salePrice: Double?
    var saleCommissionPercent: Double?
    var saleCommissionAmount: Double?
    var saleDate: String?

    var fullAddress: String {
        let num = streetNumber.isEmpty ? "" : "\(streetNumber) "
        return "\(num)\(street), \(postalCode) \(city)"
    }

    var mapsURL: URL? {
        let q = "\(fullAddress), \(country)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?q=\(q)")
    }
}
