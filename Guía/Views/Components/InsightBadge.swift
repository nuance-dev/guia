import SwiftUI

struct InsightBadge: View {
    let insight: DecisionFlowCoordinator.DecisionInsight
    
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
        case .bias: return "exclamationmark.triangle"
        case .dataQuality: return "chart.bar"
        case .stakeholder: return "person.2"
        case .sensitivity: return "arrow.up.arrow.down"
        case .tradeoff: return "arrow.left.arrow.right"
        }
    }
    
    private var severityColor: Color {
        switch insight.severity {
        case .info: return .blue
        case .warning: return .orange
        case .critical: return .red
        }
    }
} 