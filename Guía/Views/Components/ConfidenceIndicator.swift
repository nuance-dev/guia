import SwiftUI

struct ConfidenceIndicator: View {
    let score: Double
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: animateProgress ? score / 100 : 0)
                .stroke(Color.accentColor, style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Text("\(Int(score))%")
                    .font(.system(size: 24, weight: .medium))
                Text("Confidence")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            withAnimation(.spring(response: 1.5)) {
                animateProgress = true
            }
        }
    }
}