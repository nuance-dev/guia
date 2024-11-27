import SwiftUI

struct FactorComparisonView: View {
    let options: [Option]
    let currentFactor: Factor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Factor Comparison")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 20) {
                ForEach(options) { option in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(option.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        if let score = option.scores[currentFactor.id] {
                            ScoreIndicator(
                                score: score,
                                weight: currentFactor.weight
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }
}