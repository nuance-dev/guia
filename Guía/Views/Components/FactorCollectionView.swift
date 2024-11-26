import SwiftUI

struct FactorCollectionView: View {
    @Binding var factors: [Factor]
    @State private var newFactorName = ""
    @FocusState private var isFocused: Bool
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    private let maxFactors = 5
    private let suggestions = [
        "Cost", "Time", "Quality", "Risk", "Impact",
        "Effort", "Long-term benefit", "Short-term gain"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerSection
            
            if factors.isEmpty {
                suggestionsGrid
            }
            
            factorList
            
            if factors.count < maxFactors {
                factorInput
            }
            
            navigationSection
        }
        .onChange(of: factors.count) { _, count in
            flowManager.updateProgressibility(count >= 2)
        }
    }
    
    private var navigationSection: some View {
        HStack {
            Button(action: { flowManager.goBack() }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
                .foregroundColor(.white.opacity(0.6))
            }
            .opacity(flowManager.canGoBack ? 1 : 0)
            
            Spacer()
            
            if factors.count >= 2 {
                Button("Continue", action: { flowManager.advanceStep() })
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .cornerRadius(6)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What factors matter most?")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
            
            Text("Add the key aspects that will influence your decision")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    private var factorList: some View {
        VStack(spacing: 12) {
            ForEach($factors) { $factor in
                HStack(spacing: 16) {
                    Text(factor.name)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Weight indicator dots
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(Color.white.opacity(
                                    index < Int(factor.weight * 5) ? 0.8 : 0.2
                                ))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            factor.weight = Double((factor.weight * 5).rounded(.up)) / 5
                        }
                    }
                    
                    Button(action: { removeFactor(factor) }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        // Cycle through weight levels (0.2, 0.4, 0.6, 0.8, 1.0)
                        let currentLevel = Int(factor.weight * 5)
                        let nextLevel = (currentLevel + 1) % 6
                        factor.weight = Double(nextLevel) / 5
                    }
                }
            }
        }
    }
    
    private var factorInput: some View {
        HStack {
            TextField("Add a factor", text: $newFactorName)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
                .focused($isFocused)
                .onSubmit { addFactor() }
            
            Button(action: addFactor) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: [])
            .disabled(newFactorName.isEmpty)
        }
    }
    
    private var suggestionsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
            ForEach(suggestions, id: \.self) { suggestion in
                Button(action: { addSuggestion(suggestion) }) {
                    Text(suggestion)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func addFactor() {
        guard !newFactorName.isEmpty && factors.count < maxFactors else { return }
        withAnimation(.spring(response: 0.3)) {
            factors.append(Factor(name: newFactorName, weight: 0.5, score: 0))
            newFactorName = ""
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

// Helper view for factor rows
private struct FactorRow: View {
    let factor: Factor
    
    var body: some View {
        HStack {
            Text(factor.name)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// Add this extension at the bottom of the file
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
