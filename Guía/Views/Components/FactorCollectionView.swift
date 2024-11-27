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
        "Long-term benefits",
        "Risk level",
        "Emotional satisfaction",
        "Learning opportunity",
        "Resource availability",
        "Flexibility/Adaptability",
        "Immediate impact",
        "Future potential",
        "Effort required",
        "Quality/Reliability",
        "Alignment with goals"
    ]
    
    var body: some View {
        ScrollView {
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
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 120, maximum: 200), spacing: 8)
                        ], spacing: 8) {
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
