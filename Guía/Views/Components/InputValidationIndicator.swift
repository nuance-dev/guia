import SwiftUI

struct InputValidationIndicator: View {
    let isValid: Bool
    @State private var opacity = 0.0
    
    var body: some View {
        Circle()
            .fill(isValid ? Color.accentColor : Color.clear)
            .frame(width: 4, height: 4)
            .opacity(opacity)
            .onChange(of: isValid) { _, newValue in
                withAnimation(.easeInOut(duration: 0.6)) {
                    opacity = newValue ? 0.6 : 0.0
                }
            }
    }
} 