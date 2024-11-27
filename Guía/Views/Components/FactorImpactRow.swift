import SwiftUI

struct FactorImpactRow: View {
    let factor: Factor
    let showWeight: Bool
    @State private var isHovered = false
    
    private var impactColor: Color {
        switch factor.score {
        case 0.7...: return .green
        case 0.4..<0.7: return .blue
        case 0.0..<0.4: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Factor name with weight
            HStack(spacing: 6) {
                Text(factor.name)
                    .font(.system(size: 14))
                if showWeight {
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("\(Int(factor.weight * 100))%")
                        .foregroundColor(.secondary)
                        .font(.system(size: 13))
                }
            }
            
            Spacer()
            
            // Impact visualization
            HStack(spacing: 8) {
                // Animated progress bar
                GeometryReader { geometry in
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            Capsule()
                                .fill(impactColor.opacity(0.8))
                                .frame(width: geometry.size.width * factor.normalizedScore)
                        )
                }
                .frame(width: 60, height: 4)
                
                // Score percentage
                Text("\(Int(factor.normalizedScore * 100))%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(impactColor)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(isHovered ? 0.05 : 0.02))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    VStack {
        FactorImpactRow(factor: Factor(name: "Cost", weight: 0.8, score: 1.0), showWeight: true)
        FactorImpactRow(factor: Factor(name: "Time", weight: 0.5, score: -0.2), showWeight: true)
        FactorImpactRow(factor: Factor(name: "Risk", weight: 0.7, score: -0.9), showWeight: true)
    }
    .padding()
    .background(Color.black)
} 