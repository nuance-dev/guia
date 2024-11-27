import SwiftUI

struct AnalysisView: View {
    let options: [Option]
    let factors: [Factor]
    @EnvironmentObject private var decisionContext: DecisionContext
    
    private var bestOption: Option? {
        options.max(by: { $0.confidenceScore < $1.confidenceScore })
    }
    
    var body: some View {
        ScrollView {
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
                        .padding(.top, 8)
                    }
                }
                
                // Confidence comparison
                VStack(alignment: .leading, spacing: 16) {
                    Text("Confidence Analysis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    VStack(spacing: 12) {
                        ForEach(options) { option in
                            ConfidenceIndicator(
                                score: option.confidenceScore / 100,
                                label: option.name
                            )
                        }
                    }
                }
                
                // Factor comparison grid
                FactorComparisonGrid(options: options)
                
                // Detailed analysis for each option
                ForEach(options) { option in
                    OptionDetailView(
                        option: option,
                        isRecommended: option.id == bestOption?.id
                    )
                }
            }
            .padding(24)
        }
    }
}


