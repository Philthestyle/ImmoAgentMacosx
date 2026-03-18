import SwiftUI

struct KPICardView: View {
    let icon: String
    let value: String
    let label: String
    var changePercent: Double? = nil
    var subtitle: String? = nil
    var isHero: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isHero ? .white.opacity(0.9) : .blue)

                Spacer()

                if let changePercent {
                    HStack(spacing: 2) {
                        Image(systemName: changePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption2)
                        Text(String(format: "%+.1f%%", changePercent))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(
                        isHero
                            ? .white.opacity(0.9)
                            : (changePercent >= 0 ? .green : .red)
                    )
                }
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(isHero ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(isHero ? .white.opacity(0.8) : .secondary)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(isHero ? .white.opacity(0.7) : .secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isHero {
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                Color(.controlBackgroundColor)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(isHero ? 0.15 : 0.06), radius: isHero ? 8 : 4, y: 2)
    }
}

#Preview {
    HStack {
        KPICardView(icon: "house.fill", value: "2", label: "Ventes", changePercent: 12.5, isHero: true)
        KPICardView(icon: "eurosign.circle", value: "485 000 \u{20AC}", label: "CA Factur\u{00E9}", subtitle: "~388 000 \u{20AC} net estim\u{00E9}")
        KPICardView(icon: "building.2", value: "12", label: "Biens en cours")
        KPICardView(icon: "chart.line.uptrend.xyaxis", value: "242 500 \u{20AC}", label: "Prix moyen", changePercent: -3.2)
    }
    .padding()
    .frame(width: 1000)
}
