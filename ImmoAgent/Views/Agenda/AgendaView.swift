import SwiftUI

struct AgendaView: View {
    let dataService: DataServiceProtocol

    private var visits: [Visit] { dataService.visits }

    private var today: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private var todayVisits: [Visit] { visits.filter { $0.date == today } }
    private var upcomingVisits: [Visit] { visits.filter { $0.date > today && $0.status == .scheduled } }
    private var pastVisits: [Visit] { visits.filter { $0.date < today || $0.status == .completed } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Agenda")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("\(visits.filter { $0.status == .scheduled }.count) visites planifiées")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        // add visit
                    } label: {
                        Label("Nouvelle visite", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                if visits.isEmpty {
                    EmptyStateView(
                        icon: "calendar",
                        title: "Aucune visite",
                        description: "Planifiez votre première visite depuis la fiche d'un bien.",
                        actionTitle: "Voir les biens"
                    ) { }
                } else {
                    if !todayVisits.isEmpty {
                        visitSection(title: "Aujourd'hui", sectionVisits: todayVisits, accent: .blue)
                    }
                    if !upcomingVisits.isEmpty {
                        visitSection(title: "À venir", sectionVisits: upcomingVisits, accent: .orange)
                    }
                    if !pastVisits.isEmpty {
                        visitSection(title: "Passées", sectionVisits: pastVisits, accent: .secondary)
                    }
                }
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
    }

    private func visitSection(title: String, sectionVisits: [Visit], accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accent)
                    .frame(width: 4, height: 20)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("(\(sectionVisits.count))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(sectionVisits) { visit in
                visitRow(visit)
            }
        }
    }

    private func visitRow(_ visit: Visit) -> some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(visit.time)
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
                Text(visit.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)

            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(visit.propertyTitle)
                        .font(.headline)
                    Spacer()
                    BadgeView(text: visit.status.label, variant: visit.status == .scheduled ? .info : visit.status == .completed ? .success : .danger)
                }

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text(visit.clientName)
                            .font(.subheadline)
                    }

                    if !visit.notes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(visit.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}
