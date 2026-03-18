import SwiftUI

struct MandatesView: View {
    @StateObject private var viewModel: MandatesViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(dataService: DataServiceProtocol) {
        _viewModel = StateObject(wrappedValue: MandatesViewModel(dataService: dataService))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                summaryCards
                filterBar
                mandateList
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Mandats")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Gestion de vos mandats de vente")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                // new mandate action
            } label: {
                Label("Nouveau mandat", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        HStack(spacing: 16) {
            summaryCard(icon: "doc.text.fill", value: "\(viewModel.total)", label: "Total", color: .blue)
            summaryCard(icon: "checkmark.circle.fill", value: "\(viewModel.complete)", label: "Complets", color: .green)
            summaryCard(icon: "clock.fill", value: "\(viewModel.inProgress)", label: "En cours", color: .orange)
            summaryCard(icon: "pencil.circle.fill", value: "\(viewModel.draft)", label: "Brouillons", color: .gray)
        }
    }

    private func summaryCard(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
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

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.statusFilters, id: \.self) { filter in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.filterStatus = filter
                    }
                } label: {
                    Text(filter)
                        .font(.subheadline)
                        .fontWeight(viewModel.filterStatus == filter ? .semibold : .regular)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            viewModel.filterStatus == filter
                                ? Color.blue.opacity(0.15)
                                : Color(.controlBackgroundColor)
                        )
                        .foregroundStyle(
                            viewModel.filterStatus == filter ? .blue : .primary
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }

    // MARK: - Mandate List

    private var mandateList: some View {
        VStack(spacing: 14) {
            if viewModel.filteredMandates.isEmpty {
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "Aucun mandat",
                    description: "Aucun mandat ne correspond \u{00E0} vos filtres."
                )
                .frame(height: 200)
            } else {
                ForEach(viewModel.filteredMandates) { mandate in
                    mandateCard(mandate)
                        .onTapGesture {
                            coordinator.showMandateDetail(mandate.id)
                        }
                }
            }
        }
    }

    private func mandateCard(_ mandate: Mandate) -> some View {
        let completionPct = Double(mandate.completionPercent) / 100.0

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mandate.propertyTitle)
                        .font(.headline)
                    Text(mandate.ownerName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    BadgeView(text: mandate.type.label, variant: .info)
                    BadgeView.forMandateStatus(mandate.status)
                }
            }

            HStack {
                Image(systemName: "eurosign.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(mandate.askingPrice))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("(\(String(format: "%.1f", mandate.commissionPercent))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(mandate.startDate) \u{2192} \(mandate.endDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Documents")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(mandate.providedCount)/\(mandate.documents.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                    Text("(\(mandate.completionPercent)%)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor(completionPct).opacity(0.15))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor(completionPct))
                            .frame(width: geo.size.width * completionPct, height: 6)
                    }
                }
                .frame(height: 6)
            }

            if mandate.requiredMissing > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(mandate.requiredMissing) document(s) obligatoire(s) manquant(s)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(20)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private func progressColor(_ progress: Double) -> Color {
        if progress >= 1.0 { return .green }
        if progress >= 0.5 { return .blue }
        if progress >= 0.25 { return .orange }
        return .red
    }
}

#Preview {
    MandatesView(dataService: DataService())
        .environment(AppCoordinator())
        .frame(width: 900, height: 700)
}
