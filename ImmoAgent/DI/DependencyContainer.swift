import Foundation

protocol DataServiceProtocol: AnyObject {
    var properties: [Property] { get set }
    var clients: [Client] { get set }
    var mandates: [Mandate] { get set }
    var visits: [Visit] { get set }
    var phoneCalls: [PhoneCall] { get set }
    var profile: UserProfile { get set }
    var isDemo: Bool { get set }

    func toggleDemo()
    func addProperty(_ property: Property)
    func addClient(_ client: Client)
    func addMandate(_ mandate: Mandate)
    func addVisit(_ visit: Visit)
}

final class DependencyContainer: ObservableObject {
    let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol = DataService()) {
        self.dataService = dataService
    }
}
