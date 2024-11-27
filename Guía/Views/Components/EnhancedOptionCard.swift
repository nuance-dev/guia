import SwiftUI

struct EnhancedOptionCard: View {
    let option: Option
    let isBest: Bool
    let factors: [Factor]
    @State private var expandedFactor: UUID?
    
    private var sortedFactors: [Factor] {
        option.factors.sorted { $0.weightedImpact > $1.weightedImpact }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with option name and confidence
            HStack {
                Text(option.name)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isBest ? .accentColor : .white)
                
                Spacer()
                
                // Real confidence calculation
                let confidence = calculateConfidence()
                Text("\(Int(confidence))%")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            // Factor analysis section
            VStack(alignment: .leading, spacing: 12) {
                ForEach(sortedFactors) { factor in
                    FactorAnalysisRow(
                        factor: factor,
                        score: option.scores[factor.id] ?? 0,
                        isExpanded: expandedFactor == factor.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                expandedFactor = expandedFactor == factor.id ? nil : factor.id
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
    
    private func calculateConfidence() -> Double {
        let weightedScores = option.factors.reduce(0.0) { sum, factor in
            guard let score = option.scores[factor.id] else { return sum }
            return sum + (factor.weight * ((score + 1) / 2))
        }
        
        let totalWeight = option.factors.reduce(0.0) { $0 + $1.weight }
        guard totalWeight > 0 else { return 0 }
        
        return (weightedScores / totalWeight) * 100
    }
}

struct FactorAnalysisRow: View {
    let factor: Factor
    let score: Double
    let isExpanded: Bool
    let onTap: () -> Void
    
    private var impactColor: Color {
        switch score {
        case 0.6...: return .green.opacity(0.8)
        case 0.2..<0.6: return .yellow.opacity(0.8)
        default: return .red.opacity(0.8)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(factor.name)
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                // Score visualization
                HStack(spacing: 8) {
                    ScoreBar(score: score, weight: factor.weight)
                    Text("\(Int((score + 1) * 50))%")
                        .font(.system(size: 13))
                        .foregroundColor(impactColor)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight: \(Int(factor.weight * 100))%")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Impact: \(String(format: "%.1f", factor.weightedImpact))")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.leading, 4)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.02))
        .cornerRadius(8)
        .onTapGesture(perform: onTap)
    }
}

struct ScoreBar: View {
    let score: Double
    let weight: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                
                Rectangle()
                    .fill(Color.accentColor.opacity(weight))
                    .frame(width: geometry.size.width * ((score + 1) / 2))
            }
        }
        .frame(width: 60, height: 4)
        .cornerRadius(2)
    }
} 