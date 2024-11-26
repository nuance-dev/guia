import SwiftUI

struct FactorScoringView: View {
    @Binding var options: [Option]
    @State private var currentFactorIndex = 0
    @State private var showingComparison = false
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
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
            
            // Factor navigation
            if showingComparison {
                FactorComparisonGrid(options: options)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
            
            HStack(spacing: 16) {
                Text("Worse")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [.red.opacity(0.3), .clear, .green.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        // Thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                            .offset(x: (geometry.size.width * ((score + 1) / 2)) - 8)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newScore = (value.location.x / geometry.size.width) * 2 - 1
                                        score = max(-1, min(1, newScore))
                                        onChange(score)
                                    }
                            )
                    }
                }
                .frame(height: 16)
                
                Text("Better")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
} 