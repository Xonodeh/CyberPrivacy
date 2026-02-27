import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                LinearGradient(
                    colors: [Color.blue, Color.cyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("CyberPrivacy")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .kerning(-0.3)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 0, style: .continuous)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.primary.opacity(0.1)),
            alignment: .bottom
        )
    }
}
