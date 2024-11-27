import SwiftUI

struct FactorScoringView: View {
    @Binding var options: [Option]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var currentFactorIndex = 0
    @State private var showComparison = false
    @State private var showInsights = false
    
    private var currentFactor: Factor? {
        guard let firstOption = options.first,
              currentFactorIndex < firstOption.factors.count else { return nil }
        return firstOption.factors[currentFactorIndex]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Context header
            VStack(alignment: .leading, spacing: 16) {
                if let factor = currentFactor {
                    Text(factor.name)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text("Factor Weight:")
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(Int(factor.weight * 100))%")
                            .foregroundColor(.accentColor)
                    }
                    .font(.system(size: 14))
                }
                
                // Progress pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let firstOption = options.first {
                            ForEach(firstOption.factors.indices, id: \.self) { index in
                                ProgressPill(
                                    text: firstOption.factors[index].name,
                                    isActive: index == currentFactorIndex,
                                    isCompleted: index < currentFactorIndex
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        currentFactorIndex = index
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Scoring cards
            VStack(spacing: 24) {
                ForEach(options.indices, id: \.self) { index in
                    ScoringCard(
                        option: options[index].name,
                        score: bindingForScore(optionIndex: index),
                        isActive: true
                    )
                }
            }
        }
        .padding(24)
    }
    
    private func bindingForScore(optionIndex: Int) -> Binding<Double> {
        Binding(
            get: {
                guard let factorId = currentFactor?.id else { return 0 }
                return options[optionIndex].scores[factorId] ?? 0
            },
            set: { newValue in
                guard let factorId = currentFactor?.id else { return }
                var updatedOption = options[optionIndex]
                updatedOption.scores[factorId] = newValue
                options[optionIndex] = updatedOption
                
                checkFactorProgress()
            }
        )
    }
    
    private func checkFactorProgress() {
        let allScored = options.allSatisfy { option in
            guard let factorId = currentFactor?.id else { return false }
            return option.scores[factorId] != nil
        }
        
        if allScored {
            withAnimation(.spring(response: 0.3)) {
                if currentFactorIndex < (options.first?.factors.count ?? 0) - 1 {
                    currentFactorIndex += 1
                } else {
                    flowManager.updateProgressibility(true)
                }
            }
        }
    }
}

