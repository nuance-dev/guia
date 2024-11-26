import SwiftUI

struct StageButton: View {
    let stage: DecisionStage
    let isSelected: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: stage.systemImage)
                    .font(.system(size: 16))
                Text(stage.title)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.1) : .clear)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(.accent)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                    .padding(4)
            }
        }
    }
}