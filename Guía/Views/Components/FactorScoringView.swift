import SwiftUI

struct FactorScoringView: View {
    @Binding var options: [Option]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var currentFactorIndex = 0
    @State private var showingComparison = false
    @State private var suggestions: [String] = []
    
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
            
            // Progress indicator
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
                            score: binding(for: $option, factor: factor),
                            onChange: { _ in checkProgress() }
                        )
                    }
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
                
                // Suggestions
                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggestions")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        applySuggestion(suggestion)
                                    }) {
                                        Text(suggestion)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.white.opacity(0.05))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.02))
                    )
                }
                
                // Navigation
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
                    }
                }
                .padding(.top, 16)
            }
        }
        .onChange(of: currentFactorIndex) { oldValue, newValue in
            updateSuggestions()
        }
        .onAppear {
            updateSuggestions()
        }
    }
    
    private func binding(for option: Binding<Option>, factor: Factor) -> Binding<Double> {
        Binding(
            get: { option.wrappedValue.scores[factor.id] ?? 0.5 },
            set: { newValue in
                var updatedOption = option.wrappedValue
                updatedOption.scores[factor.id] = newValue
                option.wrappedValue = updatedOption
            }
        )
    }
    
    private func checkProgress() {
        let allFactorsScored = options.allSatisfy { option in
            guard let factor = currentFactor else { return false }
            return option.scores[factor.id] != nil
        }
        
        flowManager.updateProgressibility(allFactorsScored)
    }
    
    private func nextFactor() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentFactorIndex += 1
        }
    }
    
    private func previousFactor() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentFactorIndex -= 1
        }
    }
    
    private func updateSuggestions() {
        guard let factor = currentFactor else { return }
        suggestions = generateSuggestions(for: factor)
    }
    
    private func generateSuggestions(for factor: Factor) -> [String] {
        ["Excellent fit", "Good match", "Neutral", "Poor fit", "Not applicable"]
    }
    
    private func applySuggestion(_ suggestion: String) {
        guard let factor = currentFactor else { return }
        let score = scoreMappings[suggestion] ?? 0.5
        
        withAnimation(.spring()) {
            for i in 0..<options.count {
                var option = options[i]
                option.scores[factor.id] = score
                options[i] = option
            }
        }
        
        checkProgress()
    }
    
    private let scoreMappings: [String: Double] = [
        "Excellent fit": 1.0,
        "Good match": 0.75,
        "Neutral": 0.5,
        "Poor fit": 0.25,
        "Not applicable": 0.0
    ]
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