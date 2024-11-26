import SwiftUI

struct InsightBadge: View {
    let insight: Decision.Insight
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(severityColor)
            
            Text(insight.message)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(severityColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var iconName: String {
        switch insight.type {
        case .pattern: return "chart.bar"
        case .bias: return "exclamationmark.triangle"
        case .suggestion: return "lightbulb"
        case .warning: return "exclamationmark.circle"
        }
    }
    
    private var severityColor: Color {
        switch insight.type {
        case .pattern: return .blue
        case .bias: return .orange
        case .suggestion: return .green
        case .warning: return .red
        }
    }
} 