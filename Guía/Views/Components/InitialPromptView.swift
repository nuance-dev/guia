import SwiftUI

struct InitialPromptView: View {
    @EnvironmentObject private var decisionContext: DecisionContext
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @FocusState private var isTextFieldFocused: Bool
    @State private var showPlaceholder = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 16) {
                Text("What's on your mind?")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Let's break down your decision into clear steps")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .opacity(0.8)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                TextField("", text: $decisionContext.mainDecision)
                    .font(.system(size: 17))
                    .textFieldStyle(.plain)
                    .placeholder(when: decisionContext.mainDecision.isEmpty) {
                        Text("e.g. Should I switch jobs?")
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .focused($isTextFieldFocused)
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                    .overlay(
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: isTextFieldFocused ? nil : 0)
                            .animation(.spring(response: 0.4), value: isTextFieldFocused)
                    )
            }
            .padding(.top, 8)
            
            if !decisionContext.mainDecision.isEmpty {
                Button {
                    withAnimation {
                        flowManager.advanceStep()
                    }
                } label: {
                    HStack {
                        Text("Begin")
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onChange(of: decisionContext.mainDecision) { _, newValue in
            flowManager.updateProgressibility(!newValue.isEmpty)
        }
    }
}

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