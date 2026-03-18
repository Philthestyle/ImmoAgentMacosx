import SwiftUI

struct PropertyDetailView: View {
    let property: Property
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Text(isEditing ? "Modifier le bien" : "D\u{00E9}tail du bien")
                    .font(.headline)

                Spacer()

                Button {
                    isEditing.toggle()
                } label: {
                    Label(isEditing ? "Annuler" : "Modifier", systemImage: isEditing ? "xmark" : "pencil")
                }
                .buttonStyle(.bordered)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(20)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    coverSection
                    priceSection
                    addressSection
                    descriptionSection
                    specsSection
                    ownerSection
                    mandateSection

                    if let url = property.listingUrl, !url.isEmpty {
                        listingSection(url: url)
                    }

                    filesSection
                }
                .padding(24)
            }
        }
        .background(Color(.windowBackgroundColor))
    }

    // MARK: - Sections

    private var coverSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: property.status == .sold
                            ? [Color.green.opacity(0.2), Color.green.opacity(0.05)]
                            : [Color.blue.opacity(0.1), Color.gray.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)

            VStack(spacing: 12) {
                Image(systemName: property.status == .sold ? "trophy.fill" : "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundStyle(property.status == .sold ? .yellow : .secondary.opacity(0.4))

                if property.status == .sold {
                    Text("VENDU")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                } else {
                    Text("Ajouter des photos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var priceSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(CurrencyFormatter.format(property.price))
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                if let salePrice = property.salePrice {
                    Text(CurrencyFormatter.format(salePrice))
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    + Text(" (prix de vente)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                BadgeView.forPropertyStatus(property.status)
                BadgeView(text: property.type.label, variant: .info)
            }
        }
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("Adresse")

            if let url = property.mapsURL {
                Link(destination: url) {
                    HStack(spacing: 6) {
                        Image(systemName: "map.fill")
                            .font(.caption)
                        Text(property.fullAddress)
                            .font(.body)
                    }
                }
                .foregroundStyle(.blue)
            } else {
                Text(property.fullAddress)
                    .font(.body)
            }
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("Description")
            Text(property.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Caract\u{00E9}ristiques")
            HStack(spacing: 20) {
                if property.bedrooms > 0 {
                    specItem(icon: "bed.double.fill", label: "Chambres", value: "\(property.bedrooms)")
                }
                if property.bathrooms > 0 {
                    specItem(icon: "shower.fill", label: "Salles de bain", value: "\(property.bathrooms)")
                }
                specItem(icon: "square.dashed", label: "Surface", value: "\(Int(property.surface)) m\u{00B2}")
                if property.rooms > 0 {
                    specItem(icon: "door.left.hand.open", label: "Pi\u{00E8}ces", value: "\(property.rooms)")
                }
            }
        }
    }

    private func specItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var ownerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Propri\u{00E9}taire")

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 44, height: 44)
                    let initials = property.ownerName.split(separator: " ")
                        .prefix(2)
                        .compactMap { $0.first.map(String.init) }
                        .joined()
                        .uppercased()
                    Text(initials)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(property.ownerName)
                        .font(.body)
                        .fontWeight(.semibold)

                    HStack(spacing: 16) {
                        if !property.ownerPhone.isEmpty {
                            Label(property.ownerPhone, systemImage: "phone.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        if !property.ownerEmail.isEmpty {
                            Label(property.ownerEmail, systemImage: "envelope.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
    }

    private var mandateSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Mandat")

            if property.mandateId != nil {
                BadgeView(text: "Mandat actif", variant: .success)
            } else {
                BadgeView(text: "Sans mandat", variant: .warning)
            }
        }
    }

    private func listingSection(url: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("Annonce en ligne")

            if let link = URL(string: url) {
                Link(destination: link) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                        Text(url)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                }
                .foregroundStyle(.blue)
            }
        }
    }

    private var filesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Documents")

            HStack(spacing: 12) {
                fileItem(icon: "doc.text.fill", name: "Compromis.pdf")
                fileItem(icon: "photo.fill", name: "Photos.zip")
                fileItem(icon: "doc.fill", name: "PEB.pdf")
            }

            Button {
                // add file action
            } label: {
                Label("Ajouter un document", systemImage: "plus.circle")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
        }
    }

    private func fileItem(icon: String, name: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .tracking(0.8)
    }
}

#Preview {
    PropertyDetailView(property: DataService.demoProperties[1])
        .frame(width: 650, height: 700)
}
