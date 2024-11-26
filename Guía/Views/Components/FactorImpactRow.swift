import SwiftUI

struct FactorImpactRow: View {
    let factor: Factor
    
    private var impactColor: Color {
        let score = factor.score
        if score > 0.6 {
            return .green.opacity(0.8)
        } else if score > 0.3 {
            return .yellow.opacity(0.8)
        } else {
            return .red.opacity(0.8)
        }
    }
    
    var body: some View {
        HStack {
            Text(factor.name)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            // Impact indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(impactColor)
                    .frame(width: 8, height: 8)
                
                Text(String(format: "%.0f%%", factor.score * 100))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        FactorImpactRow(factor: Factor(name: "Cost", weight: 0.8, score: 1.0))
        FactorImpactRow(factor: Factor(name: "Time", weight: 0.5, score: -0.2))
        FactorImpactRow(factor: Factor(name: "Risk", weight: 0.7, score: -0.9))
    }
    .padding()
    .background(Color.black)
} 