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
    
    private var allCurrentFactorsScored: Bool {
        guard let factor = currentFactor else { return false }
        return options.allSatisfy { option in
            option.factors.contains { $0.id == factor.id && $0.score != 0 }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Progress and context
            VStack(alignment: .leading, spacing: 16) {
                if let factor = currentFactor {
                    Text(factor.name)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    // Factor weight indicator
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
                    .padding(.horizontal, 1)
                }
            }
            
            // Scoring interface
            VStack(spacing: 24) {
                ForEach($options) { $option in
                    ScoringCard(
                        option: option.name,
                        score: bindingForFactor(option: $option, factorId: currentFactor?.id),
                        onChange: { checkFactorProgress() }
                    )
                }
            }
            
            // Comparison toggle
            if allCurrentFactorsScored {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showComparison.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: showComparison ? "chart.bar.fill" : "chart.bar")
                        Text(showComparison ? "Hide Comparison" : "Compare Scores")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
                
                if showComparison {
                    FactorComparisonGrid(options: options)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func bindingForFactor(option: Binding<Option>, factorId: UUID?) -> Binding<Double> {
        guard let id = factorId else { return .constant(0) }
        
        return Binding(
            get: {
                option.wrappedValue.factors.first { $0.id == id }?.score ?? 0
            },
            set: { newValue in
                if let index = option.wrappedValue.factors.firstIndex(where: { $0.id == id }) {
                    option.wrappedValue.factors[index].score = newValue
                }
            }
        )
    }
    
    private func checkFactorProgress() {
        if allCurrentFactorsScored {
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

struct ScoringCard: View {
    let option: String
    @Binding var score: Double
    let onChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(option)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
            
            // Enhanced slider with better visual feedback
            CustomSlider(value: $score, onChange: onChange)
            
            // Score labels
            HStack {
                Text("Poor fit")
                Spacer()
                Text("Perfect fit")
            }
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let onChange: () -> Void
    @GestureState private var isDragging = false
    
    var body: some View {
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
                .frame(width: max(0, min(geometry.size.width * CGFloat(value), geometry.size.width)), height: 4)
                .cornerRadius(2)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .position(x: max(8, min(geometry.size.width * CGFloat(value), geometry.size.width - 8)), 
                            y: geometry.size.height / 2)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        let newValue = min(max(gesture.location.x / geometry.size.width, 0), 1)
                        value = Double(newValue)
                        onChange()
                    }
            )
        }
        .frame(height: 24)
    }
} 