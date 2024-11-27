import SwiftUI

struct TitleBarAccessory: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 3, height: 3)
                .opacity(0.6)
            
            Text("Guía")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .opacity(0.8)
        }
        .frame(height: 28)
        .padding(.horizontal, 12)
    }
}
