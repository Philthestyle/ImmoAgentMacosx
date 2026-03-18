import SwiftUI

struct PropertyCardView: View {
    let property: Property

    var body: some View {
        if property.status == .sold {
            soldCard
        } else {
            standardCard
        }
    }

    // MARK: - Sold Card (Victory Style)

    private var soldCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Trophy header
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Spacer()
                BadgeView(text: "VENDU", variant: .sold)
            }

            // Commission as hero
            if let commission = property.saleCommissionAmount {
                Text(CurrencyFormatter.format(commission))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Commission")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Divider()
                .background(.white.opacity(0.3))

            // Property info
            Text(property.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text(property.fullAddress)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))

            HStack {
                if let salePrice = property.salePrice {
                    Text(CurrencyFormatter.format(salePrice))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                Text(CurrencyFormatter.format(property.price))
                    .font(.caption)
                    .strikethrough()
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Specs
            Text(specsSummary)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.65, blue: 0.3),
                    Color(red: 0.1, green: 0.5, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .green.opacity(0.2), radius: 8, y: 4)
    }

    // MARK: - Standard Card

    private var standardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Cover placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)

                Image(systemName: iconForType(property.type))
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary.opacity(0.4))
            }

            // Status + type
            HStack {
                BadgeView.forPropertyStatus(property.status)
                BadgeView(text: property.type.label, variant: .info)
                Spacer()
            }

            // Price
            Text(CurrencyFormatter.format(property.price))
                .font(.title2)
                .fontWeight(.bold)

            // Title & address
            Text(property.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(property.fullAddress)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            // Specs pills
            HStack(spacing: 6) {
                if property.bedrooms > 0 {
                    specPill(icon: "bed.double.fill", text: "\(property.bedrooms) ch.")
                }
                if property.bathrooms > 0 {
                    specPill(icon: "shower.fill", text: "\(property.bathrooms) sdb")
                }
                specPill(icon: "square.dashed", text: "\(Int(property.surface)) m\u{00B2}")
            }

            Divider()

            // Owner + mandate
            HStack {
                Image(systemName: "person.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(property.ownerName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Helpers

    private var specsSummary: String {
        var parts: [String] = []
        if property.bedrooms > 0 { parts.append("\(property.bedrooms) ch.") }
        if property.bathrooms > 0 { parts.append("\(property.bathrooms) sdb") }
        parts.append("\(Int(property.surface)) m\u{00B2}")
        return parts.joined(separator: " \u{2022} ")
    }

    private func specPill(icon: String, text: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.08))
        .clipShape(Capsule())
    }

    private func iconForType(_ type: PropertyType) -> String {
        switch type {
        case .house: "house.fill"
        case .apartment: "building.fill"
        case .villa: "house.lodge.fill"
        case .land: "map.fill"
        case .commercial: "storefront.fill"
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        PropertyCardView(property: DataService.demoProperties[4]) // sold
        PropertyCardView(property: DataService.demoProperties[0]) // available
    }
    .padding()
    .frame(width: 700)
}
