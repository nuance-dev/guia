import SwiftUI

struct InitialPromptView: View {
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var decision = ""
    @State private var isValid = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 12) {
                Text("What's on your mind?")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Frame your decision in a clear, actionable way")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack {
                TypewriterTextField(
                    text: $decision,
                    placeholder: "Should I...",
                    onSubmit: { flowManager.advanceStep() }
                )
                
                InputValidationIndicator(isValid: isValid)
                    .padding(.leading, 8)
            }
        }
        .onChange(of: decision) { _, newValue in
            let valid = newValue.count >= 3
            isValid = valid
            flowManager.updateProgressibility(valid)
        }
    }
} 