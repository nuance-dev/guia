import SwiftUI

struct AnalysisView: View {
    let options: [Option]
    let factors: [Factor]
    @EnvironmentObject private var decisionContext: DecisionContext
    @State private var selectedInsight: UUID?
    @State private var showDetailedAnalysis = false
    
    // Cache the best option to avoid recalculation
    private let bestOption: Option?
    
    init(options: [Option], factors: [Factor]) {
        self.options = options
        self.factors = factors
        self.bestOption = options.max(by: { $0.confidenceScore < $1.confidenceScore })
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                if let best = bestOption {
                    RecommendationHeader(option: best)
                }
                
                KeyFactorsSection(
                    options: options,
                    factors: factors,
                    selectedInsight: $selectedInsight
                )
                
                ComparisonSection(
                    options: options,
                    factors: factors,
                    bestOptionId: bestOption?.id
                )
            }
            .padding(24)
        }
    }
}

// MARK: - Subcomponents

private struct RecommendationHeader: View {
    let option: Option
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recommended Choice")
                    .font(.system(size: 32, weight: .medium))
                Text(option.name)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            ConfidenceIndicator(score: option.confidenceScore)
        }
    }
}

private struct KeyFactorsSection: View {
    let options: [Option]
    let factors: [Factor]
    @Binding var selectedInsight: UUID?
    
    // Pre-calculate decisive factors
    private let decisiveFactors: [Factor]
    
    init(options: [Option], factors: [Factor], selectedInsight: Binding<UUID?>) {
        self.options = options
        self.factors = factors
        self._selectedInsight = selectedInsight
        
        // Calculate decisive factors once during initialization
        self.decisiveFactors = factors.filter { factor in
            let scores = options.compactMap { $0.scores[factor.id] }
            guard let maxScore = scores.max(),
                  let minScore = scores.min() else { return false }
            let difference = maxScore - minScore
            return difference > 0.4 && factor.weight > 0.6
        }
    }
    
    var body: some View {
        if !decisiveFactors.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Key Differentiators")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                ForEach(decisiveFactors) { factor in
                    DecisiveFactorRow(
                        factor: factor,
                        options: options,
                        isSelected: selectedInsight == factor.id,
                        onTap: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedInsight = selectedInsight == factor.id ? nil : factor.id
                            }
                        }
                    )
                }
            }
        }
    }
}

private struct DecisiveFactorRow: View {
    let factor: Factor
    let options: [Option]
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        DecisiveRowFactor(
            factor: factor,
            options: options
        )
        .onTapGesture(perform: onTap)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

private struct ComparisonSection: View {
    let options: [Option]
    let factors: [Factor]
    let bestOptionId: UUID?
    
    var body: some View {
        LazyVStack(spacing: 24) {
            ForEach(options) { option in
                EnhancedOptionCard(
                    option: option,
                    isBest: option.id == bestOptionId,
                    factors: factors
                )
            }
        }
    }
}




