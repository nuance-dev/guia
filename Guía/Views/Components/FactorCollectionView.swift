import SwiftUI

struct FactorCollectionView: View {
    @Binding var factors: [Factor]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var newFactorName = ""
    @FocusState private var isFocused: Bool
    private let maxFactors = 5
    
    let suggestions = [
        "Cost",
        "Time commitment",
        "Long-term impact",
        "Personal growth",
        "Risk level",
        "Emotional satisfaction",
        "Career impact",
        "Work-life balance",
        "Learning opportunity",
        "Financial security"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("What factors matter most?")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Add the key aspects that will influence your decision")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(alignment: .leading, spacing: 24) {
                // Factor input
                if factors.count < maxFactors {
                    factorInput
                }
                
                // Existing factors
                factorsSection
                
                // Suggestions
                if factors.count < maxFactors {
                    suggestionsSection
                }
            }
        }
        .onChange(of: factors.count) { _, count in
            flowManager.updateProgressibility(count >= 2)
        }
    }
    
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Suggested Factors")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                ForEach(suggestions.filter { suggestion in
                    !factors.contains { $0.name == suggestion }
                }, id: \.self) { suggestion in
                    Button(action: { addSuggestion(suggestion) }) {
                        HStack {
                            Text(suggestion)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .opacity(suggestions.isEmpty ? 0 : 1)
    }
    
    private var factorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !factors.isEmpty {
                Text("Your Decision Factors")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                ForEach(factors) { factor in
                    HStack {
                        Text(factor.name)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { removeFactor(factor) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var factorInput: some View {
        HStack {
            TextField("Add a custom factor", text: $newFactorName)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
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
