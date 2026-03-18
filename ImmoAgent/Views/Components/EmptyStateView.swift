import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.6))

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 4)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "building.2",
        title: "Aucun bien",
        description: "Ajoutez votre premier bien immobilier pour commencer.",
        actionTitle: "Ajouter un bien"
    ) {
        // action
    }
}
