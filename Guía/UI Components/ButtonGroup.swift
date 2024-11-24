import SwiftUI

struct ToolbarButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .frame(height: 36)
            .padding(.horizontal, 16)
            .foregroundColor(.primary)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ButtonDivider: View {
    var body: some View {
        Divider()
            .frame(height: 24)
    }
}

struct ButtonGroup<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            content
        }
        .background(backgroundView)
    }
    
    private var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.5))
            
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}
