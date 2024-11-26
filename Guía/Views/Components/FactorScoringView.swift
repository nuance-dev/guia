import SwiftUI

struct FactorScoringView: View {
    @Binding var options: [Option]
    @State private var currentFactorIndex = 0
    @State private var showingComparison = false
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @EnvironmentObject private var decisionContext: DecisionContext
    
    private var currentFactor: Factor? {
        guard !options.isEmpty,
              let firstOption = options.first,
              currentFactorIndex < firstOption.factors.count
        else { return nil }
        return firstOption.factors[currentFactorIndex]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Compare Options")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                if let factor = currentFactor {
                    Text("How does each option compare for '\(factor.name)'?")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Progress indicator
            if let firstOption = options.first, !firstOption.factors.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<firstOption.factors.count, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(index == currentFactorIndex ? 0.8 : 0.2))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            if let factor = currentFactor {
                // Scoring interface
                VStack(spacing: 24) {
                    ForEach($options) { $option in
                        ScoringSlider(
                            option: option.name,
                            score: binding(for: option, factor: factor),
                            onChange: { _ in checkProgress() }
                        )
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Spacer()
            
            // Factor navigation
            if showingComparison {
                FactorComparisonGrid(options: options)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Help tip
            if !showingComparison {
                ContextualHelpView(tip: "Rate how well each option performs for this factor. Consider both positive and negative impacts.")
            }
        }
        .onChange(of: currentFactorIndex) { _, _ in
            withAnimation(.spring(response: 0.3)) {
                showingComparison = currentFactorIndex >= (options.first?.factors.count ?? 0)
            }
            checkProgress()
        }
    }
    
    private func binding(for option: Option, factor: Factor) -> Binding<Double> {
        Binding(
            get: {
                if let index = option.factors.firstIndex(where: { $0.id == factor.id }) {
                    return option.factors[index].score
                }
                return 0
            },
            set: { newValue in
                if let optionIndex = options.firstIndex(where: { $0.id == option.id }),
                   let factorIndex = options[optionIndex].factors.firstIndex(where: { $0.id == factor.id }) {
                    options[optionIndex].factors[factorIndex].score = newValue
                }
            }
        )
    }
    
    private func checkProgress() {
        let isComplete = currentFactorIndex >= (options.first?.factors.count ?? 0)
        flowManager.updateProgressibility(isComplete)
    }
}

struct ScoringSlider: View {
    let option: String
    @Binding var score: Double
    let onChange: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(option)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            
            HStack {
                Text("Poor")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Slider(value: $score, in: -1...1) { _ in
                    onChange(score)
                }
                .tint(.white.opacity(0.6))
                
                Text("Excellent")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Score indicator
            HStack(spacing: 2) {
                ForEach(0..<20) { index in
                    Rectangle()
                        .fill(Color.white.opacity(
                            Double(index) / 20 <= (score + 1) / 2 ? 0.6 : 0.1
                        ))
                        .frame(height: 4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
} 