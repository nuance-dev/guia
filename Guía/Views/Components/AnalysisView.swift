import SwiftUI

struct AnalysisView: View {
    let options: [Option]
    let factors: [Factor]
    @EnvironmentObject private var decisionContext: DecisionContext
    
    private var bestOption: Option? {
        options.max(by: { $0.confidenceScore < $1.confidenceScore })
    }
    
    private func formatConfidence(_ value: Double) -> String {
        let roundedValue = Int(max(min(value, 100), 0))
        return "\(roundedValue)%"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header with decision context
            VStack(alignment: .leading, spacing: 16) {
                Text("Analysis Complete")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text(decisionContext.mainDecision)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.6))
                
                if let best = bestOption {
                    HStack(spacing: 8) {
                        Text("Recommended:")
                            .foregroundColor(.white.opacity(0.6))
                        Text(best.name)
                            .foregroundColor(.accentColor)
                    }
                    .font(.system(size: 18, weight: .medium))
                    .padding(.top, 8)
                }
            }
            
            // Options comparison
            ForEach(options, id: \.name) { option in
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(option.name)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(option.id == bestOption?.id ? .accentColor : .white)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Confidence")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text(formatConfidence(option.confidenceScore))
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    // Factor breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(option.factors) { factor in
                            HStack {
                                Text(factor.name)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                // Factor weight
                                Text("Weight: \(Int(factor.weight * 100))%")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                    .frame(width: 80)
                                
                                // Factor score
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(scoreColor(factor.score))
                                        .frame(width: 8, height: 8)
                                    Text(formatConfidence(factor.normalizedScore * 100))
                                }
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 60)
                            }
                            .font(.system(size: 14))
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    option.id == bestOption?.id ? Color.accentColor.opacity(0.3) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                )
            }
            
            // Final recommendation
            if let best = bestOption {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Why this recommendation?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(generateRecommendation(best))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                .padding(20)
                .background(Color.white.opacity(0.03))
                .cornerRadius(12)
            }
        }
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score > 0.3 {
            return .green.opacity(0.8)
        } else if score > -0.3 {
            return .yellow.opacity(0.8)
        } else {
            return .red.opacity(0.8)
        }
    }
    
    private func generateRecommendation(_ option: Option) -> String {
        let highestFactors = option.factors
            .sorted { $0.weight > $1.weight }
            .prefix(2)
            .map { "\($0.name.lowercased()) (\(Int($0.weight * 100))%)" }
            .joined(separator: " and ")
        
        return "\(option.name) stands out primarily due to its strong performance in \(highestFactors). The confidence score of \(formatConfidence(option.confidenceScore)) suggests this is a well-supported recommendation based on your inputs."
    }
}
