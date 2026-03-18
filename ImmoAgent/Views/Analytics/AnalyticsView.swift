import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel: AnalyticsViewModel
    @Environment(AppCoordinator.self) private var coordinator
    let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(dataService: dataService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                heroKPIs
                secondaryKPIs
                HStack(alignment: .top, spacing: 20) {
                    funnelSection
                    netIncomeCalculator
                }
                monthlyPerformanceTable
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Statistiques")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Analyse de votre performance commerciale")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Picker("P\u{00E9}riode", selection: $viewModel.selectedPeriod) {
                ForEach(viewModel.periods, id: \.self) { period in
                    Text(period).tag(period)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 180)
        }
    }

    // MARK: - Hero KPIs

    private var heroKPIs: some View {
        HStack(spacing: 16) {
            KPICardView(
                icon: "house.fill",
                value: "\(viewModel.stats.ventesCount)",
                label: "Ventes",
                changePercent: 12.5,
                isHero: true
            )
            KPICardView(
                icon: "eurosign.circle.fill",
                value: viewModel.stats.formattedCA,
                label: "Chiffre d'affaires",
                subtitle: "Volume total des transactions"
            )
            KPICardView(
                icon: "chart.line.uptrend.xyaxis",
                value: viewModel.stats.formattedPrixMoyen,
                label: "Prix moyen",
                changePercent: -3.2
            )
            KPICardView(
                icon: "banknote.fill",
                value: viewModel.stats.formattedCommission,
                label: "Commission brute"
            )
        }
    }

    // MARK: - Secondary KPIs

    private var secondaryKPIs: some View {
        HStack(spacing: 16) {
            clickableKPI(
                icon: "building.2.fill",
                value: "\(viewModel.stats.biensActifs)",
                label: "Biens actifs"
            ) {
                coordinator.selectedDestination = .properties
            }

            clickableKPI(
                icon: "eye.fill",
                value: "\(viewModel.stats.visitsCount)",
                label: "Visites"
            ) {
                coordinator.selectedDestination = .agenda
            }

            clickableKPI(
                icon: "doc.text.fill",
                value: "\(viewModel.stats.mandatsSignes)",
                label: "Mandats sign\u{00E9}s"
            ) {
                coordinator.selectedDestination = .mandates
            }

            secondaryKPI(icon: "percent", value: String(format: "%.1f%%", viewModel.stats.tauxConversion), label: "Taux de conversion")
        }
    }

    private func clickableKPI(icon: String, value: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.blue.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func secondaryKPI(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - Funnel

    private var funnelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.triangle.merge")
                    .foregroundStyle(.blue)
                Text("Entonnoir de conversion")
                    .font(.headline)
                Spacer()
            }

            let funnel = viewModel.funnel
            let maxVal = max(funnel.appels, 1)

            VStack(spacing: 16) {
                funnelStep(label: "Appels", value: funnel.appels, max: maxVal, color: .blue, icon: "phone.fill")
                funnelStep(label: "Prises en compte", value: funnel.prisesEnCompte, max: maxVal, color: .cyan, icon: "checkmark.circle.fill")
                funnelStep(label: "Mandats sign\u{00E9}s", value: funnel.mandats, max: maxVal, color: .orange, icon: "doc.text.fill")
                funnelStep(label: "Ventes conclues", value: funnel.ventes, max: maxVal, color: .green, icon: "trophy.fill")
            }

            // Conversion rates
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("TAUX DE CONVERSION")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                if funnel.appels > 0 {
                    conversionRow(from: "Appels", to: "Mandats", rate: Double(funnel.mandats) / Double(funnel.appels) * 100)
                    conversionRow(from: "Mandats", to: "Ventes", rate: funnel.mandats > 0 ? Double(funnel.ventes) / Double(funnel.mandats) * 100 : 0)
                    conversionRow(from: "Appels", to: "Ventes", rate: Double(funnel.ventes) / Double(funnel.appels) * 100)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private func funnelStep(label: String, value: Int, max: Int, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.12))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(value) / CGFloat(max), height: 12)
                }
            }
            .frame(height: 12)
        }
    }

    private func conversionRow(from: String, to: String, rate: Double) -> some View {
        HStack {
            Text("\(from) \u{2192} \(to)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.1f%%", rate))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(rate >= 10 ? .green : .orange)
        }
    }

    // MARK: - Net Income Calculator

    private var netIncomeCalculator: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "eurosign.arrow.circlepath")
                    .foregroundStyle(.green)
                Text("Simulateur revenu net")
                    .font(.headline)
                Spacer()
            }

            VStack(spacing: 12) {
                calculatorRow(label: "Commission brute", value: viewModel.formatted(viewModel.grossCommission), isPositive: true)

                Divider()

                calculatorRow(label: "Cotisations sociales (~20,65%)", value: "- \(viewModel.formatted(viewModel.socialCharges))", isPositive: false)
                calculatorRow(label: "Imp\u{00F4}ts estim\u{00E9}s (~45%)", value: "- \(viewModel.formatted(viewModel.taxEstimate))", isPositive: false)

                Divider()

                HStack {
                    Text("Revenu net estim\u{00E9}")
                        .font(.headline)
                    Spacer()
                    Text(viewModel.formatted(viewModel.netEstimate))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }

            Text("Estimation indicative bas\u{00E9}e sur le r\u{00E9}gime ind\u{00E9}pendant belge. Consultez votre comptable.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .italic()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private func calculatorRow(label: String, value: String, isPositive: Bool) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(isPositive ? Color.primary : Color.red)
        }
    }

    // MARK: - Monthly Performance Table

    private var monthlyPerformanceTable: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tablecells")
                    .foregroundStyle(.blue)
                Text("Performance mensuelle")
                    .font(.headline)
                Spacer()
            }

            // Header
            HStack {
                Text("Mois")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Ventes")
                    .frame(width: 80, alignment: .trailing)
                Text("CA")
                    .frame(width: 140, alignment: .trailing)
                Text("Mandats")
                    .frame(width: 80, alignment: .trailing)
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)

            Divider()

            // Rows
            ForEach(viewModel.monthlyPerformance) { month in
                HStack {
                    Text(month.month)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(month.ventes)")
                        .frame(width: 80, alignment: .trailing)
                        .fontWeight(.semibold)
                    Text(viewModel.formatted(month.ca))
                        .frame(width: 140, alignment: .trailing)
                    Text("\(month.mandats)")
                        .frame(width: 80, alignment: .trailing)
                }
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.03))
                )
            }

            // Total row
            Divider()
            HStack {
                Text("Total")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                let totalVentes = viewModel.monthlyPerformance.reduce(0) { $0 + $1.ventes }
                let totalCA = viewModel.monthlyPerformance.reduce(0.0) { $0 + $1.ca }
                let totalMandats = viewModel.monthlyPerformance.reduce(0) { $0 + $1.mandats }
                Text("\(totalVentes)")
                    .frame(width: 80, alignment: .trailing)
                    .fontWeight(.bold)
                Text(viewModel.formatted(totalCA))
                    .frame(width: 140, alignment: .trailing)
                    .fontWeight(.bold)
                Text("\(totalMandats)")
                    .frame(width: 80, alignment: .trailing)
                    .fontWeight(.bold)
            }
            .font(.subheadline)
            .padding(.horizontal, 8)
        }
        .padding(20)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    AnalyticsView(dataService: DataService())
        .environment(AppCoordinator())
        .frame(width: 1000, height: 900)
}
