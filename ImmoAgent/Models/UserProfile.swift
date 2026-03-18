import Foundation

struct UserProfile: Codable {
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var company: String
    var iban: String
    var bio: String
    var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))" }
}
