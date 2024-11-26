import SwiftUI

struct FactorComparisonGrid: View {
    let options: [Option]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Factor Comparison")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 16) {
                // Header row
                HStack {
                    Text("Factor")
                        .frame(width: 120, alignment: .leading)
                    ForEach(options) { option in
                        Text(option.name)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                
                // Factor rows
                if let factors = options.first?.factors {
                    ForEach(factors) { factor in
                        HStack(spacing: 16) {
                            Text(factor.name)
                                .frame(width: 120, alignment: .leading)
                                .foregroundColor(.white)
                            
                            ForEach(options) { option in
                                if let score = option.factors.first(where: { $0.id == factor.id })?.score {
                                    scoreIndicator(score)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }
    
    private func scoreIndicator(_ score: Double) -> some View {
        let color: Color = switch score {
            case 0.6...: .green
            case 0.3..<0.6: .yellow
            default: .red
        }
        
        return HStack(spacing: 4) {
            Circle()
                .fill(color.opacity(0.8))
                .frame(width: 8, height: 8)
            Text(String(format: "%.0f%%", (score + 1) * 50))
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
} 