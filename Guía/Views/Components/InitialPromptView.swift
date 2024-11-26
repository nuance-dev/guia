import SwiftUI

struct InitialPromptView: View {
    @State private var decision = ""
    @Environment(\.dismiss) private var dismiss
    
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
            
            TypewriterTextField(
                text: $decision,
                placeholder: "Should I...",
                onSubmit: { /* Handle submission */ }
            )
        }
    }
} 