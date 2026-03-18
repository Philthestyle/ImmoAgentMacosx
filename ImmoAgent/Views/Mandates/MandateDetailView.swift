import SwiftUI
import UniformTypeIdentifiers
import QuickLook

struct MandateDetailView: View {
    @State private var mandate: Mandate
    let dataService: DataServiceProtocol
    @Environment(AppCoordinator.self) private var coordinator
    @State private var previewURL: URL?
    @State private var dropTargetDocId: String?

    init(mandate: Mandate, dataService: DataServiceProtocol) {
        _mandate = State(initialValue: mandate)
        self.dataService = dataService
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with back button
            HStack(spacing: 12) {
                Button {
                    coordinator.dismissDetail()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Mandats")
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.blue)

                Spacer()

                BadgeView(text: mandate.type.label, variant: .info)
                BadgeView.forMandateStatus(mandate.status)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    headerSection

                    // Info cards
                    infoCards

                    Divider()

                    // Documents with drag & drop
                    documentsSection
                }
                .padding(28)
            }
        }
        .background(Color(.windowBackgroundColor))
        .quickLookPreview($previewURL)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mandate.propertyTitle)
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack(spacing: 16) {
                Label(mandate.ownerName, systemImage: "person.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label("\(mandate.startDate) \u{2192} \(mandate.endDate)", systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Info Cards

    private var infoCards: some View {
        HStack(spacing: 16) {
            infoCard(
                icon: "eurosign.circle.fill",
                title: "Prix demand\u{00E9}",
                value: CurrencyFormatter.format(mandate.askingPrice),
                color: .blue
            )
            infoCard(
                icon: "percent",
                title: "Commission",
                value: String(format: "%.1f%%", mandate.commissionPercent),
                color: .green
            )
            infoCard(
                icon: "doc.text.fill",
                title: "Documents",
                value: "\(mandate.providedCount)/\(mandate.documents.count)",
                color: .orange
            )
            infoCard(
                icon: "chart.pie.fill",
                title: "Compl\u{00E9}tion",
                value: "\(mandate.completionPercent)%",
                color: mandate.completionPercent == 100 ? .green : .blue
            )
        }
    }

    private func infoCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - Documents

    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.blue)
                Text("Documents du mandat")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()

                // Progress
                let pct = Double(mandate.completionPercent) / 100.0
                HStack(spacing: 8) {
                    ProgressView(value: pct)
                        .frame(width: 120)
                        .tint(progressColor(pct))
                    Text("\(mandate.completionPercent)%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }

            if mandate.requiredMissing > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("\(mandate.requiredMissing) document(s) obligatoire(s) manquant(s)")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            let grouped = Dictionary(grouping: mandate.documents, by: \.category)
            let categoryOrder = ["identity", "property", "legal", "technical", "financial"]
            let categories = categoryOrder.filter { grouped.keys.contains($0) }

            ForEach(categories, id: \.self) { category in
                VStack(alignment: .leading, spacing: 10) {
                    Text(categoryLabel(category))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                        .padding(.top, 4)

                    ForEach(grouped[category] ?? []) { doc in
                        documentRow(doc)
                    }
                }
            }
        }
    }

    private func documentRow(_ doc: MandateDocument) -> some View {
        let isDropTarget = dropTargetDocId == doc.id

        return HStack(spacing: 14) {
            // Status icon
            Image(systemName: doc.provided ? "checkmark.circle.fill" : "circle.dashed")
                .font(.title3)
                .foregroundStyle(doc.provided ? .green : .secondary)

            // Doc info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(doc.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if doc.required {
                        Text("*")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Text(doc.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // File info if provided
                if let fileName = doc.fileName {
                    Button {
                        if let path = doc.filePath {
                            previewURL = URL(fileURLWithPath: path)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: iconForFile(fileName))
                                .font(.caption)
                            Text(fileName)
                                .font(.caption)
                                .lineLimit(1)
                            if doc.filePath != nil {
                                Image(systemName: "eye")
                                    .font(.caption2)
                            }
                        }
                        .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            // Actions
            if doc.provided {
                if let path = doc.filePath {
                    Button {
                        NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
                    } label: {
                        Image(systemName: "folder")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Afficher dans le Finder")
                }

                Button {
                    removeFile(for: doc)
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Supprimer")
            } else {
                Text("Glisser un fichier ici")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(doc.provided ? Color.green.opacity(0.04) : Color(.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(
                    isDropTarget ? Color.blue : Color.clear,
                    style: StrokeStyle(lineWidth: 2, dash: isDropTarget ? [6, 3] : [])
                )
        )
        .onDrop(of: [.fileURL], isTargeted: Binding(
            get: { dropTargetDocId == doc.id },
            set: { dropTargetDocId = $0 ? doc.id : nil }
        )) { providers in
            handleDrop(providers: providers, for: doc)
        }
    }

    // MARK: - Drop handling

    private func handleDrop(providers: [NSItemProvider], for doc: MandateDocument) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

            DispatchQueue.main.async {
                addFile(url: url, for: doc)
            }
        }
        return true
    }

    private func addFile(url: URL, for doc: MandateDocument) {
        guard let docIndex = mandate.documents.firstIndex(where: { $0.id == doc.id }) else { return }

        let fileName = url.lastPathComponent
        mandate.documents[docIndex].provided = true
        mandate.documents[docIndex].fileName = fileName
        mandate.documents[docIndex].filePath = url.path

        dataService.updateMandate(mandate)
    }

    private func removeFile(for doc: MandateDocument) {
        guard let docIndex = mandate.documents.firstIndex(where: { $0.id == doc.id }) else { return }

        mandate.documents[docIndex].provided = false
        mandate.documents[docIndex].fileName = nil
        mandate.documents[docIndex].filePath = nil

        dataService.updateMandate(mandate)
    }

    // MARK: - Helpers

    private func categoryLabel(_ category: String) -> String {
        switch category {
        case "identity": "IDENTIT\u{00C9} & PROPRI\u{00C9}T\u{00C9}"
        case "property": "DOCUMENTS DU BIEN"
        case "legal": "DOCUMENTS L\u{00C9}GAUX & CERTIFICATS"
        case "technical": "DOCUMENTS TECHNIQUES"
        case "financial": "DOCUMENTS FINANCIERS"
        default: category.uppercased()
        }
    }

    private func progressColor(_ progress: Double) -> Color {
        if progress >= 1.0 { return .green }
        if progress >= 0.5 { return .blue }
        if progress >= 0.25 { return .orange }
        return .red
    }

    private func iconForFile(_ name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.text.fill"
        case "jpg", "jpeg", "png", "heic": return "photo.fill"
        case "zip", "rar": return "doc.zipper"
        case "doc", "docx": return "doc.richtext"
        case "xls", "xlsx": return "tablecells"
        default: return "doc.fill"
        }
    }
}

#Preview {
    MandateDetailView(
        mandate: DataService.demoMandates[1],
        dataService: DataService()
    )
    .environment(AppCoordinator())
    .frame(width: 900, height: 700)
}
