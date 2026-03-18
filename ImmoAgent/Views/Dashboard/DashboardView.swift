import SwiftUI

struct DashboardView: View {
    let dataService: DataServiceProtocol
    @StateObject private var viewModel: DashboardViewModel

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        _viewModel = StateObject(wrappedValue: DashboardViewModel(dataService: dataService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                kpiCards
                commissionBanner
                HStack(alignment: .top, spacing: 20) {
                    phoneCallsCard
                    funnelCard
                }
                HStack(alignment: .top, spacing: 20) {
                    revenuePlaceholder
                    netSimulatorPlaceholder
                }
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
        .navigationTitle("Dashboard")
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tableau de bord")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Vue d'ensemble de votre activit\u{00E9}")
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

            Button {
                viewModel.objectWillChange.send()
            } label: {
                Label("Voir mes stats", systemImage: "chart.bar.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - KPI Cards

    private var kpiCards: some View {
        HStack(spacing: 16) {
            KPICardView(
                icon: "house.fill",
                value: "\(viewModel.ventesCount)",
                label: "Ventes",
                changePercent: 12.5,
                isHero: true
            )

            KPICardView(
                icon: "eurosign.circle.fill",
                value: CurrencyFormatter.format(viewModel.caFacture),
                label: "CA Factur\u{00E9}",
                subtitle: "~\(CurrencyFormatter.format(viewModel.netEstimate)) net estim\u{00E9}"
            )

            KPICardView(
                icon: "building.2.fill",
                value: "\(viewModel.biensActifs)",
                label: "Biens en cours"
            )

            KPICardView(
                icon: "chart.line.uptrend.xyaxis",
                value: CurrencyFormatter.format(viewModel.prixMoyen),
                label: "Prix moyen",
                changePercent: -3.2
            )
        }
    }

    // MARK: - Commission Banner

    private var commissionBanner: some View {
        HStack {
            Image(systemName: "banknote.fill")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Commission totale")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(CurrencyFormatter.format(viewModel.commission))
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
            Text("3% du CA factur\u{00E9}")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [Color.green, Color(red: 0.1, green: 0.7, blue: 0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .green.opacity(0.2), radius: 8, y: 4)
    }

    // MARK: - Phone Calls Card

    private var phoneCallsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundStyle(.blue)
                Text("Appels t\u{00E9}l\u{00E9}phoniques")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.pendingCalls.count) en attente")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Scheduled
            if !viewModel.scheduledCalls.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PLANIFI\u{00C9}S")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.scheduledCalls) { call in
                        phoneCallRow(call)
                    }
                }
            }

            // Unscheduled
            if !viewModel.unscheduledCalls.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SANS HORAIRE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.unscheduledCalls) { call in
                        phoneCallRow(call)
                    }
                }
            }

            // Done
            if !viewModel.doneCalls.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EFFECTU\u{00C9}S")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.doneCalls) { call in
                        phoneCallRow(call)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private func phoneCallRow(_ call: PhoneCall) -> some View {
        HStack(spacing: 10) {
            Button {
                viewModel.toggleCallDone(call)
            } label: {
                Image(systemName: call.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(call.done ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(call.contactName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .strikethrough(call.done)

                    if call.priority == .high {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                Text(call.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let time = call.time {
                Text(time)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Funnel Card

    private var funnelCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.triangle.merge")
                    .foregroundStyle(.blue)
                Text("Entonnoir de conversion")
                    .font(.headline)
                Spacer()
            }

            let maxVal = max(viewModel.funnelAppels, 1)

            VStack(spacing: 12) {
                funnelBar(label: "Appels", value: viewModel.funnelAppels, max: maxVal, color: .blue)
                funnelBar(label: "Prises en compte", value: viewModel.funnelPrisesEnCompte, max: maxVal, color: .cyan)
                funnelBar(label: "Mandats", value: viewModel.funnelMandats, max: maxVal, color: .orange)
                funnelBar(label: "Ventes", value: viewModel.funnelVentes, max: maxVal, color: .green)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private func funnelBar(label: String, value: Int, max: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / CGFloat(max), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Placeholders

    private var revenuePlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.blue)
                Text("\u{00C9}volution du chiffre d'affaires")
                    .font(.headline)
                Spacer()
            }

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.05))
                .frame(height: 200)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text("Graphique CA mensuel")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private var netSimulatorPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "eurosign.arrow.circlepath")
                    .foregroundStyle(.green)
                Text("Simulateur revenu net")
                    .font(.headline)
                Spacer()
            }

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.green.opacity(0.05))
                .frame(height: 200)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text("Calculateur net / brut")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

#Preview {
    DashboardView(dataService: DataService())
        .frame(width: 1000, height: 900)
}
