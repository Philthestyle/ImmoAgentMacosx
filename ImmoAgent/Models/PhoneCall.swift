import Foundation

enum CallPriority: String, Codable, CaseIterable {
    case high, medium, low
}

struct PhoneCall: Identifiable, Codable {
    let id: String
    var contactName: String
    var phone: String
    var reason: String
    var priority: CallPriority
    var time: String?
    var done: Bool
}
