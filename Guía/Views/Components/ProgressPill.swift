import SwiftUI

struct ProgressPill: View {
    let text: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(text)
                .font(.system(size: 13, weight: isActive ? .medium : .regular))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(backgroundColor)
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(isActive ? 0.1 : 0.05), lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        if isActive { return .accentColor }
        if isCompleted { return .green }
        return .white.opacity(0.3)
    }
    
    private var textColor: Color {
        if isActive { return .white }
        if isCompleted { return .white.opacity(0.8) }
        return .white.opacity(0.6)
    }
    
    private var backgroundColor: Color {
        if isActive { return .white.opacity(0.08) }
        if isCompleted { return .white.opacity(0.05) }
        return .clear
    }
} 