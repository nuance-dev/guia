import SwiftUI

struct ScoringCard: View {
    let option: String
    @Binding var score: Double
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(option)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
            
            CustomSlider(value: $score)
                .opacity(isActive ? 1 : 0.5)
            
            // Score labels
            HStack {
                Text("Poor fit")
                Spacer()
                Text("Perfect fit")
            }
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isActive ? 0.08 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isActive ? 0.2 : 0.05), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}