import SwiftUI

struct SettingsView: View {
    let dataService: DataServiceProtocol

    @State private var profile: UserProfile
    @State private var originalProfile: UserProfile
    @State private var notifyNewLeads: Bool = true
    @State private var notifyVisitReminder: Bool = true
    @State private var notifyMandateExpiry: Bool = true
    @State private var notifyWeeklyReport: Bool = false
    @State private var preferredAppearance: String = "Système"

    private let appearances = ["Système", "Clair", "Sombre"]

    var hasChanges: Bool {
        profile.firstName != originalProfile.firstName ||
        profile.lastName != originalProfile.lastName ||
        profile.email != originalProfile.email ||
        profile.phone != originalProfile.phone ||
        profile.company != originalProfile.company ||
        profile.iban != originalProfile.iban ||
        profile.bio != originalProfile.bio
    }

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
        let p = dataService.profile
        _profile = State(initialValue: p)
        _originalProfile = State(initialValue: p)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Paramètres")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                profileSection
                Divider()
                notificationsSection
                Divider()
                appearanceSection

                if hasChanges {
                    saveBar
                }
            }
            .padding(28)
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Profile

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Profil")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Text(profile.initials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }

                    Button("Changer la photo") {}
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        fieldGroup(label: "Prénom", text: $profile.firstName)
                        fieldGroup(label: "Nom", text: $profile.lastName)
                    }
                    HStack(spacing: 16) {
                        fieldGroup(label: "Email", text: $profile.email)
                        fieldGroup(label: "Téléphone", text: $profile.phone)
                    }
                    HStack(spacing: 16) {
                        fieldGroup(label: "Société", text: $profile.company)
                        fieldGroup(label: "IBAN", text: $profile.iban)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Bio")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        TextEditor(text: $profile.bio)
                            .font(.body)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(.controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(24)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private func fieldGroup(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextField(label, text: text)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(spacing: 0) {
                toggleRow(icon: "person.badge.plus", title: "Nouveaux leads", subtitle: "Notification à chaque nouveau prospect", isOn: $notifyNewLeads)
                Divider().padding(.leading, 48)
                toggleRow(icon: "clock.badge.exclamationmark", title: "Rappel de visite", subtitle: "30 min avant chaque visite planifiée", isOn: $notifyVisitReminder)
                Divider().padding(.leading, 48)
                toggleRow(icon: "doc.badge.clock", title: "Expiration de mandat", subtitle: "7 jours avant l'expiration", isOn: $notifyMandateExpiry)
                Divider().padding(.leading, 48)
                toggleRow(icon: "chart.bar.doc.horizontal", title: "Rapport hebdomadaire", subtitle: "Résumé de performance chaque lundi", isOn: $notifyWeeklyReport)
            }
            .padding(16)
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
    }

    private func toggleRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.medium)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: isOn).toggleStyle(.switch).labelsHidden()
        }
        .padding(.vertical, 10)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Apparence")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 16) {
                ForEach(appearances, id: \.self) { appearance in
                    Button {
                        preferredAppearance = appearance
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(appearance == "Clair" ? Color(white: 0.95) : appearance == "Sombre" ? Color(white: 0.15) : Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 56)
                                Image(systemName: appearance == "Clair" ? "sun.max.fill" : appearance == "Sombre" ? "moon.fill" : "circle.lefthalf.filled")
                                    .font(.title2)
                                    .foregroundStyle(appearance == "Clair" ? .orange : appearance == "Sombre" ? .yellow : .blue)
                            }
                            Text(appearance)
                                .font(.subheadline)
                                .fontWeight(preferredAppearance == appearance ? .semibold : .regular)
                        }
                        .padding(12)
                        .background(preferredAppearance == appearance ? Color.blue.opacity(0.1) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(preferredAppearance == appearance ? Color.blue : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
    }

    // MARK: - Save Bar

    private var saveBar: some View {
        HStack {
            Spacer()
            Button("Annuler") {
                profile = originalProfile
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button("Enregistrer") {
                dataService.profile = profile
                originalProfile = profile
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(20)
        .background(
            Color(.controlBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
