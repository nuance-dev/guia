import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var style: Style = .primary
    var size: Size = .regular
    
    enum Style {
        case primary
        case secondary
        case ghost
    }
    
    enum Size {
        case small
        case regular
        case large
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: size.fontSize, weight: .medium))
            }
            .frame(height: size.height)
            .padding(.horizontal, size.padding)
            .background {
                switch style {
                case .primary:
                    Color.accentColor
                case .secondary:
                    Color.secondary.opacity(0.1)
                case .ghost:
                    Color.clear
                }
            }
            .foregroundColor(style == .primary ? .white : .primary)
            .cornerRadius(size.cornerRadius)
            .overlay {
                if style == .ghost {
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private extension ActionButton.Size {
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .regular: return 40
        case .large: return 48
        }
    }
    
    var padding: CGFloat {
        switch self {
        case .small: return 12
        case .regular: return 16
        case .large: return 20
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 13
        case .regular: return 15
        case .large: return 16
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 12
        case .regular: return 14
        case .large: return 16
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 8
        case .regular: return 10
        case .large: return 12
        }
    }
} 