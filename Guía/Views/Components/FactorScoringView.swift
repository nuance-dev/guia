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
                option.factors.first(where: { $0.id == factor.id })?.score ?? 0.5
            },
            set: { newValue in
                if let optionIndex = options.firstIndex(where: { $0.id == option.id }),
                   let factorIndex = options[optionIndex].factors.firstIndex(where: { $0.id == factor.id }) {
                    withAnimation(.spring(response: 0.3)) {
                        options[optionIndex].factors[factorIndex].score = newValue
                    }
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
        VStack(alignment: .leading, spacing: 8) {
            Text(option)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // Gradient track
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.red.opacity(0.8),
                            Color.yellow.opacity(0.8),
                            Color.green.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * CGFloat(score), height: 4)
                    .cornerRadius(2)
                }
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 16, height: 16)
                        .offset(x: (geometry.size.width * CGFloat(score)) - 8)
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newScore = min(max(value.location.x / geometry.size.width, 0), 1)
                            score = Double(newScore)
                            onChange(score)
                        }
                )
            }
            .frame(height: 24)
        }
    }
} 