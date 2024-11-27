import SwiftUI

struct ConfidenceBar: View {
    let score: Double
    let maxWidth: CGFloat
    @State private var width: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 4)
                .cornerRadius(2)
            
            // Animated fill
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.6)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 4)
                .cornerRadius(2)
        }
        .frame(width: maxWidth)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                width = maxWidth * score
            }
        }
    }
} 