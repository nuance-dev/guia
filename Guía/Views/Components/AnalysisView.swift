import SwiftUI

struct AnalysisView: View {
    let options: [Option]
    let factors: [Factor]
    
    @State private var showDetails = false
    @State private var selectedOption: Option?
    
    private var confidenceScore: Double {
        guard options.count >= 2 else { return 0 }
        let scores = options.map { option in
            factors.reduce(0) { $0 + ($1.weight * $1.score) }
        }
        let difference = abs(scores[0] - scores[1])
        return min(difference * 2, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header with confidence
            VStack(alignment: .leading, spacing: 16) {
                Text("Analysis Complete")
                    .font(.system(size: 32, weight: .medium))
                
                ConfidenceIndicator(value: confidenceScore)
                    .frame(height: 4)
                    .frame(maxWidth: 200)
            }
            
            // Options comparison
            ForEach(options, id: \.name) { option in
                OptionCard(option: option, factors: factors)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedOption = option
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OptionCard: View {
    let option: Option
    let factors: [Factor]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(option.name)
                .font(.system(size: 24, weight: .medium))
            
            // Factor impacts
            VStack(alignment: .leading, spacing: 12) {
                ForEach(factors) { factor in
                    FactorImpactRow(factor: factor)
                }
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}
