import SwiftUI

enum EventType: String, CaseIterable, Identifiable {
    case visit = "Visite"
    case phoneCall = "Appel t\u{00E9}l\u{00E9}phonique"
    case meeting = "RDV physique"
    case emailFollowup = "Relance email"
    case signing = "Signature"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .visit: "eye.fill"
        case .phoneCall: "phone.fill"
        case .meeting: "person.2.fill"
        case .emailFollowup: "envelope.fill"
        case .signing: "signature"
        }
    }

    var color: Color {
        switch self {
        case .visit: .blue
        case .phoneCall: .green
        case .meeting: .purple
        case .emailFollowup: .orange
        case .signing: .red
        }
    }
}

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

    private var todayCalls: [PhoneCall] { dataService.phoneCalls.filter { !$0.done } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Agenda")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        let scheduled = visits.filter { $0.status == .scheduled }.count
                        let pending = todayCalls.count
                        Text("\(scheduled) visite\(scheduled > 1 ? "s" : "") planifi\u{00E9}e\(scheduled > 1 ? "s" : ""), \(pending) appel\(pending > 1 ? "s" : "") en attente")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    Menu {
                        ForEach(EventType.allCases) { type in
                            Button {
                                // create event of this type
                            } label: {
                                Label(type.rawValue, systemImage: type.icon)
                            }
                        }
                    } label: {
                        Label("Nouvel \u{00E9}v\u{00E9}nement", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                if visits.isEmpty && todayCalls.isEmpty {
                    EmptyStateView(
                        icon: "calendar",
                        title: "Aucun \u{00E9}v\u{00E9}nement",
                        description: "Planifiez votre premier \u{00E9}v\u{00E9}nement en cliquant sur 'Nouvel \u{00E9}v\u{00E9}nement'.",
                        actionTitle: "Voir les biens"
                    ) { }
                } else {
                    // Phone calls section
                    if !todayCalls.isEmpty {
                        callsSection
                    }

                    if !todayVisits.isEmpty {
                        visitSection(title: "Visites aujourd'hui", sectionVisits: todayVisits, accent: .blue)
                    }
                    if !upcomingVisits.isEmpty {
                        visitSection(title: "Visites \u{00E0} venir", sectionVisits: upcomingVisits, accent: .orange)
                    }
                    if !pastVisits.isEmpty {
                        visitSection(title: "Visites pass\u{00E9}es", sectionVisits: pastVisits, accent: .secondary)
                    }
                }
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Calls Section

    private var callsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green)
                    .frame(width: 4, height: 20)
                Text("Appels en attente")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("(\(todayCalls.count))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ForEach(todayCalls) { call in
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        if let time = call.time {
                            Text(time)
                                .font(.title3)
                                .fontWeight(.bold)
                                .monospacedDigit()
                        } else {
                            Text("--:--")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 80)

                    Rectangle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 2)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text(call.contactName)
                                .font(.headline)
                            Spacer()
                            priorityBadge(call.priority)
                        }

                        Text(call.reason)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(call.phone)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(16)
                .background(Color(.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
            }
        }
    }

    private func priorityBadge(_ priority: CallPriority) -> some View {
        let (text, color): (String, Color) = {
            switch priority {
            case .high: ("Urgent", .red)
            case .medium: ("Normal", .orange)
            case .low: ("Basse", .secondary)
            }
        }()
        return Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - Visits Section

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
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
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

                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.shield.checkmark")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(visit.agent)
                            .font(.caption)
                            .foregroundStyle(.secondary)
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

#Preview {
    AgendaView(dataService: DataService())
        .frame(width: 900, height: 700)
}
