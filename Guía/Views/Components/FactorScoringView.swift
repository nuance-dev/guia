import SwiftUI

struct FactorScoringView: View {
    @Binding var options: [Option]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var currentFactorIndex = 0
    @State private var showComparison = false
    
    private var currentFactor: Factor? {
        guard let firstOption = options.first,
              currentFactorIndex < firstOption.factors.count else { return nil }
        return firstOption.factors[currentFactorIndex]
    }
    
    private func syncFactorsAcrossOptions() {
        guard let firstOption = options.first else { return }
        for index in options.indices where index > 0 {
            options[index].factors = firstOption.factors
        }
    }
    
    private func bindingForScore(optionIndex: Int) -> Binding<Double> {
        Binding(
            get: {
                guard let factorId = currentFactor?.id else { return 0 }
                return options[optionIndex].scores[factorId] ?? 0
            },
            set: { newValue in
                guard let factorId = currentFactor?.id else { return }
                var updatedOptions = options
                updatedOptions[optionIndex].scores[factorId] = newValue
                options = updatedOptions
                
                // Check if all options have been scored for current factor
                let allScored = options.allSatisfy { option in
                    option.scores[factorId] != nil
                }
                
                // Only update progressibility, don't auto-advance
                if allScored {
                    flowManager.updateProgressibility(true)
                }
            }
        )
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
                
                // Progress pills with explicit navigation
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let firstOption = options.first {
                            ForEach(firstOption.factors.indices, id: \.self) { index in
                                ProgressPill(
                                    text: firstOption.factors[index].name,
                                    isActive: index == currentFactorIndex,
                                    isCompleted: isFactorCompleted(index)
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
            
            // Navigation buttons
            HStack {
                Spacer()
                if currentFactorIndex < (options.first?.factors.count ?? 0) - 1 {
                    Button("Next Factor") {
                        advanceToNextFactor()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isCurrentFactorCompleted())
                }
            }
        }
        .padding(24)
        .onAppear {
            syncFactorsAcrossOptions()
        }
    }
    
    private func isFactorCompleted(_ index: Int) -> Bool {
        guard let factorId = options.first?.factors[index].id else { return false }
        return options.allSatisfy { option in
            option.scores[factorId] != nil
        }
    }
    
    private func isCurrentFactorCompleted() -> Bool {
        isFactorCompleted(currentFactorIndex)
    }
    
    private func advanceToNextFactor() {
        guard isCurrentFactorCompleted(),
              currentFactorIndex < (options.first?.factors.count ?? 0) - 1 else { return }
        
        withAnimation(.spring(response: 0.3)) {
            currentFactorIndex += 1
            // Reset progressibility for new factor
            flowManager.updateProgressibility(false)
        }
    }
}

