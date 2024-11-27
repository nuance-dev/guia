import SwiftUI

struct FactorCollectionView: View {
    @Binding var factors: [Factor]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var newFactor = ""
    @FocusState private var isInputFocused: Bool
    @State private var showSuggestions = false
    
    private let maxFactors = 5
    private let suggestions = [
        "Cost/Budget",
        "Time investment",
        "Personal growth",
        "Impact on others",
        "Long-term benefits"
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
            
            // Factors list
            VStack(spacing: 16) {
                ForEach(factors) { factor in
                    FactorRow(factor: factor) {
                        withAnimation {
                            factors.removeAll { $0.id == factor.id }
                        }
                    }
                }
                
                if factors.count < maxFactors {
                    HStack {
                        TextField("Add a factor", text: $newFactor)
                            .textFieldStyle(.plain)
                            .focused($isInputFocused)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.03))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(isInputFocused ? 0.1 : 0.05), lineWidth: 1)
                            )
                            .onSubmit(addFactor)
                    }
                }
            }
            
            // Suggestions
            if showSuggestions && factors.count < maxFactors {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggestions")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    SuggestionFlowLayout(spacing: 8) {
                        ForEach(suggestions.filter { suggestion in
                            !factors.contains { $0.name == suggestion }
                        }, id: \.self) { suggestion in
                            SuggestionPill(text: suggestion) {
                                addSuggestion(suggestion)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.02))
                .cornerRadius(8)
            }
        }
        .onChange(of: factors.count) { _, count in
            flowManager.updateProgressibility(count >= 2)
        }
        .onAppear {
            withAnimation(.easeIn.delay(0.5)) {
                showSuggestions = true
            }
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
}

struct SuggestionPill: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.03))
                .cornerRadius(16)
        }
        .buttonStyle(SuggestionButtonStyle())
    }
}

struct FactorRow: View {
    let factor: Factor
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(factor.name)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: onDelete) {
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
