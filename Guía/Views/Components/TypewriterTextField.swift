import SwiftUI

struct PlaceholderModifier: ViewModifier {
    let placeholder: String
    let showPlaceholder: Bool
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceholder {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.3))
            }
            content
        }
    }
}

extension View {
    func placeholder(when shouldShow: Bool, placeholder: String) -> some View {
        modifier(PlaceholderModifier(placeholder: placeholder, showPlaceholder: shouldShow))
    }
}

struct TypewriterTextField: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: () -> Void
    
    @State private var isEditing = false
    @State private var displayText = ""
    @State private var cursorOpacity = 1.0
    
    var body: some View {
        HStack {
            TextField("", text: $text)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .tint(.white)
                .textFieldStyle(.plain)
                .placeholder(when: text.isEmpty, placeholder: placeholder)
                .onChange(of: text) { oldValue, newValue in
                    animateText(newValue)
                }
                .onSubmit {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        onSubmit()
                    }
                }
            
            if isEditing {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 24)
                    .opacity(cursorOpacity)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true),
                        value: cursorOpacity
                    )
            }
        }
        .onAppear {
            startCursorAnimation()
        }
    }
    
    private func animateText(_ newValue: String) {
        guard !newValue.isEmpty else {
            displayText = ""
            return
        }
        
        let typewriterDelay = 0.05
        for (index, character) in newValue.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + typewriterDelay * Double(index)) {
                displayText += String(character)
            }
        }
    }
    
    private func startCursorAnimation() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            cursorOpacity = 0.0
        }
    }
} 