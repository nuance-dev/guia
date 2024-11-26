import SwiftUI

struct FactorScoringView: View {
    @Binding var options: [Option]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var currentFactorIndex = 0
    @State private var showingComparison = false
    
    private var currentFactor: Factor? {
        guard let firstOption = options.first,
              currentFactorIndex < firstOption.factors.count else { return nil }
        return firstOption.factors[currentFactorIndex]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                if let factor = currentFactor {
                    Text("How well does each option satisfy:")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(factor.name)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Progress indicator with labels
            if let firstOption = options.first, !firstOption.factors.isEmpty {
                VStack(spacing: 8) {
                    // Factor progress dots
                    HStack(spacing: 4) {
                        ForEach(0..<firstOption.factors.count, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(index == currentFactorIndex ? 0.8 : 0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    // Factor progress text
                    Text("Factor \(currentFactorIndex + 1) of \(firstOption.factors.count)")
                        .font(.system(size: 12))
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
                
                // Navigation buttons
                HStack {
                    if currentFactorIndex > 0 {
                        Button(action: previousFactor) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .foregroundColor(.white.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    if let firstOption = options.first,
                       currentFactorIndex < firstOption.factors.count - 1 {
                        Button(action: nextFactor) {
                            HStack(spacing: 4) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.return, modifiers: [])
                    }
                }
                .padding(.top, 16)
            }
        }
        .onAppear {
            currentFactorIndex = 0
            checkProgress()
        }
    }
    
    private func nextFactor() {
        withAnimation(.spring(response: 0.3)) {
            currentFactorIndex += 1
            checkProgress()
        }
    }
    
    private func previousFactor() {
        withAnimation(.spring(response: 0.3)) {
            currentFactorIndex -= 1
            checkProgress()
        }
    }
    
    private func binding(for option: Option, factor: Factor) -> Binding<Double> {
        Binding(
            get: {
                if let existingFactor = option.factors.first(where: { $0.id == factor.id }) {
                    return existingFactor.score
                }
                // Initialize with default score if not found
                return 0.5
            },
            set: { newValue in
                if let optionIndex = options.firstIndex(where: { $0.id == option.id }) {
                    if let factorIndex = options[optionIndex].factors.firstIndex(where: { $0.id == factor.id }) {
                        options[optionIndex].factors[factorIndex].score = newValue
                    } else {
                        // If factor doesn't exist, create it
                        var newFactor = factor
                        newFactor.score = newValue
                        options[optionIndex].factors.append(newFactor)
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
                    .frame(width: max(0, min(geometry.size.width * CGFloat(score), geometry.size.width)), height: 4)
                    .cornerRadius(2)
                    
                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: 16, height: 16)
                        .position(x: max(8, min(geometry.size.width * CGFloat(score), geometry.size.width - 8)), 
                                y: geometry.size.height / 2)
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newScore = min(max(value.location.x / geometry.size.width, 0), 1)
                            withAnimation(.interactiveSpring()) {
                                score = Double(newScore)
                                onChange(score)
                            }
                        }
                )
            }
            .frame(height: 24)
        }
    }
} 