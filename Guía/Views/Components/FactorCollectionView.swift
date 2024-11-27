import SwiftUI

struct FactorCollectionView: View {
    @Binding var factors: [Factor]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @EnvironmentObject private var decisionContext: DecisionContext
    @State private var newFactor = ""
    @FocusState private var isInputFocused: Bool
    
    private let maxFactors = 5
    private let suggestions = [
        "Cost/Budget",
        "Time investment",
        "Personal growth",
        "Impact on others",
        "Long-term benefits",
        "Risk level",
        "Emotional satisfaction",
        "Career advancement",
        "Work-life balance",
        "Learning opportunity"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("What factors matter most?")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Add the key aspects that will influence your decision")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Options display
            VStack(spacing: 16) {
                ForEach(decisionContext.options) { option in
                    OptionDisplay(option: option, isSelected: false, showScore: false)
                }
            }
            
            // Factors section
            VStack(alignment: .leading, spacing: 24) {
                if factors.count < maxFactors {
                    // Factor input
                    HStack {
                        TextField("Add a factor (e.g. Time investment)", text: $newFactor)
                            .textFieldStyle(.plain)
                            .focused($isInputFocused)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .onSubmit {
                                addFactor()
                            }
                        
                        if !newFactor.isEmpty {
                            Button(action: addFactor) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(isInputFocused ? 0.05 : 0.02))
                    .cornerRadius(8)
                }
                
                // Existing factors
                if !factors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(factors) { factor in
                            HStack {
                                Text(factor.name)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { removeFactor(factor) }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(8)
                        }
                    }
                }
                
                // Suggestions
                if factors.count < maxFactors {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Suggested Factors")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        
                        SuggestionFlowLayout(spacing: 8) {
                            ForEach(suggestions.filter { suggestion in
                                !factors.contains { $0.name == suggestion }
                            }, id: \.self) { suggestion in
                                Button(action: { addSuggestion(suggestion) }) {
                                    Text(suggestion)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.03))
                                        .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: factors.count) { _, count in
            flowManager.updateProgressibility(count >= 2)
        }
    }
    
    private func addFactor() {
        guard !newFactor.isEmpty && factors.count < maxFactors else { return }
        withAnimation(.spring(response: 0.3)) {
            factors.append(Factor(name: newFactor, weight: 0.5, score: 0))
            newFactor = ""
        }
    }
    
    private func addSuggestion(_ suggestion: String) {
        guard factors.count < maxFactors else { return }
        withAnimation(.spring(response: 0.3)) {
            factors.append(Factor(name: suggestion, weight: 0.5, score: 0))
        }
    }
    
    private func removeFactor(_ factor: Factor) {
        withAnimation(.spring(response: 0.3)) {
            factors.removeAll { $0.id == factor.id }
        }
    }
}

// Helper view for flowing layout of suggestions
struct SuggestionFlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, frame) in result.frames {
            subviews[index].place(at: frame.origin, proposal: ProposedViewSize(frame.size))
        }
    }
    
    private struct FlowResult {
        var size: CGSize = .zero
        var frames: [(Int, CGRect)] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentPosition = CGPoint.zero
            var lineHeight: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let viewSize = subview.sizeThatFits(.unspecified)
                
                if currentPosition.x + viewSize.width > maxWidth && currentPosition.x > 0 {
                    currentPosition.x = 0
                    currentPosition.y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append((index, CGRect(origin: currentPosition, size: viewSize)))
                lineHeight = max(lineHeight, viewSize.height)
                currentPosition.x += viewSize.width + spacing
                size.width = max(size.width, currentPosition.x)
            }
            
            size.height = currentPosition.y + lineHeight
        }
    }
}