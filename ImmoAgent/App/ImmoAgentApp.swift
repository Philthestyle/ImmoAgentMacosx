import SwiftUI

@main
struct ImmoAgentApp: App {
    @StateObject private var container = DependencyContainer()
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                .environment(coordinator)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .defaultSize(width: 1400, height: 900)
        .windowToolbarStyle(.unified)
    }
}

// MARK: - EUR Formatting

enum CurrencyFormatter {
    static let eur: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = Locale(identifier: "fr_BE")
        f.maximumFractionDigits = 0
        return f
    }()

    static func format(_ value: Double) -> String {
        eur.string(from: NSNumber(value: value)) ?? "\(Int(value)) \u{20AC}"
    }
}
