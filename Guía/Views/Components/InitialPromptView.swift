import SwiftUI

struct InitialPromptView: View {
    @EnvironmentObject private var decisionContext: DecisionContext
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @FocusState private var isTextFieldFocused: Bool
    @State private var isHovered = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 48) {
                Spacer()
                
                // Icon with gradient
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 48))
                    .foregroundStyle(.linearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .padding(.bottom, 24)
                
                VStack(alignment: .center, spacing: 16) {
                    Text("What's on your mind?")
                        .font(.system(size: 32, weight: .medium))
                        .multilineTextAlignment(.center)
                    
                    Text("Let's break down your decision into clear steps")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    TextField("", text: $decisionContext.mainDecision)
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: min(400, geometry.size.width - 40))
                        .placeholder(when: decisionContext.mainDecision.isEmpty) {
                            Text("e.g. Should I switch jobs?")
                                .foregroundColor(.secondary.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .focused($isTextFieldFocused)
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                        .frame(maxWidth: min(400, geometry.size.width - 40))
                        .overlay(
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: isTextFieldFocused ? min(400, geometry.size.width - 40) : 0)
                                .animation(.spring(response: 0.4), value: isTextFieldFocused)
                        )
                }
                
                if !decisionContext.mainDecision.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            flowManager.advanceStep()
                        }
                    } label: {
                        HStack {
                            Text("Begin")
                                .fontWeight(.medium)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .frame(width: 120)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor)
                                .opacity(isHovered ? 0.9 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .onHover { hover in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isHovered = hover
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
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