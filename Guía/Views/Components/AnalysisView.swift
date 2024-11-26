import SwiftUI

struct AnalysisView: View {
    let options: [Option]
    let factors: [Factor]
    
    private var bestOption: Option? {
        options.max(by: { $0.confidenceScore < $1.confidenceScore })
    }
    
    private func formatConfidence(_ value: Double) -> String {
        let roundedValue = Int(max(min(value, 100), 0))
        return "\(roundedValue)%"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header with confidence
            VStack(alignment: .leading, spacing: 16) {
                Text("Analysis Complete")
                    .font(.system(size: 32, weight: .medium))
                
                if let best = bestOption {
                    Text("Recommended: \(best.name)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            }
            
            // Options comparison
            ForEach(options, id: \.name) { option in
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(option.name)
                            .font(.system(size: 24, weight: .medium))
                        Spacer()
                        Text(formatConfidence(option.confidenceScore))
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                    
                    // Factor breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(option.factors) { factor in
                            HStack {
                                Text(factor.name)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text(formatConfidence(factor.normalizedScore * 100))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.03))
                .cornerRadius(16)
            }
        }
    }
}
