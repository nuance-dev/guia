import SwiftUI

struct AnalysisView: View {
    let options: [Option]
    let factors: [Factor]
    @EnvironmentObject private var decisionContext: DecisionContext
    @State private var selectedOption: Option.ID?
    
    private var bestOption: Option? {
        options.max(by: { $0.confidenceScore < $1.confidenceScore })
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
            
            // Options summary cards
            VStack(spacing: 16) {
                ForEach(options) { option in
                    OptionSummaryCard(
                        option: option,
                        isSelected: selectedOption == option.id,
                        isBest: option.id == bestOption?.id
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedOption = selectedOption == option.id ? nil : option.id
                        }
                    }
                }
            }
            
            // Detailed view when option is selected
            if let selectedId = selectedOption,
               let option = options.first(where: { $0.id == selectedId }) {
                OptionDetailView(
                    option: option,
                    isRecommended: option.id == bestOption?.id
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Confidence comparison when no option is selected
            if selectedOption == nil {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Confidence Analysis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    ForEach(options) { option in
                        ConfidenceBar(
                            score: option.confidenceScore / 100,
                            maxWidth: 200
                        )
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}


