import SwiftUI

enum BadgeVariant {
    case success, warning, danger, info, sold

    var backgroundColor: Color {
        switch self {
        case .success: Color.green.opacity(0.15)
        case .warning: Color.orange.opacity(0.15)
        case .danger: Color.red.opacity(0.15)
        case .info: Color.blue.opacity(0.15)
        case .sold: Color.green.opacity(0.2)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .success: .green
        case .warning: .orange
        case .danger: .red
        case .info: .blue
        case .sold: Color(red: 0.1, green: 0.6, blue: 0.2)
        }
    }
}

struct BadgeView: View {
    let text: String
    let variant: BadgeVariant

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(variant.backgroundColor)
            .foregroundStyle(variant.foregroundColor)
            .clipShape(Capsule())
    }
}

extension BadgeView {
    static func forPropertyStatus(_ status: PropertyStatus) -> BadgeView {
        switch status {
        case .available: BadgeView(text: status.label, variant: .info)
        case .underOffer: BadgeView(text: status.label, variant: .warning)
        case .sold: BadgeView(text: status.label, variant: .sold)
        case .rented: BadgeView(text: status.label, variant: .info)
        }
    }

    static func forClientStatus(_ status: ClientStatus) -> BadgeView {
        switch status {
        case .new: BadgeView(text: status.label, variant: .info)
        case .contacted: BadgeView(text: status.label, variant: .info)
        case .visiting: BadgeView(text: status.label, variant: .warning)
        case .negotiating: BadgeView(text: status.label, variant: .warning)
        case .closed: BadgeView(text: status.label, variant: .success)
        }
    }

    static func forMandateStatus(_ status: MandateStatus) -> BadgeView {
        switch status {
        case .draft: BadgeView(text: status.label, variant: .info)
        case .inProgress: BadgeView(text: status.label, variant: .warning)
        case .complete: BadgeView(text: status.label, variant: .success)
        case .expired: BadgeView(text: status.label, variant: .danger)
        case .cancelled: BadgeView(text: status.label, variant: .danger)
        }
    }

    static func forVisitStatus(_ status: VisitStatus) -> BadgeView {
        switch status {
        case .scheduled: BadgeView(text: status.label, variant: .info)
        case .completed: BadgeView(text: status.label, variant: .success)
        case .cancelled: BadgeView(text: status.label, variant: .danger)
        case .noShow: BadgeView(text: status.label, variant: .warning)
        }
    }
}
