import SwiftUI

struct DecisionCard: View {
    let decision: Decision
    @StateObject private var viewModel: DecisionViewModel
    
    init(decision: Decision) {
        self.decision = decision
        self._viewModel = StateObject(wrappedValue: DecisionViewModel(decision: decision))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(decision.title)
                        .font(.system(size: 15, weight: .medium))
                    
                    Text(timeframeDescription)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ProgressIndicator(progress: viewModel.completionProgress)
            }
            
            // Smart Insights
            if let primaryInsight = viewModel.primaryInsight {
                InsightBadge(insight: primaryInsight)
            }
            
            // Quick Actions
            if !decision.evaluation.isComplete {
                ActionButton(
                    title: viewModel.nextActionTitle,
                    subtitle: viewModel.nextActionDescription,
                    icon: viewModel.nextActionIcon,
                    action: viewModel.performNextAction
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.windowBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    private var timeframeDescription: String {
        switch decision.context.timeframe {
        case .immediate: return "Urgent decision"
        case .shortTerm: return "Due soon"
        case .longTerm: return "Strategic decision"
        }
    }
}

extension DecisionFlowCoordinator.DecisionInsight {
    init(from insight: Decision.Insight) {
        self.init(
            type: .init(from: insight.type),
            message: insight.message,
            severity: .info,
            recommendation: insight.recommendation ?? ""
        )
    }
}

extension DecisionFlowCoordinator.DecisionInsight.InsightType {
    init(from insightType: Decision.Insight.InsightType) {
        switch insightType {
        case .pattern: self = .sensitivity
        case .bias: self = .bias
        case .suggestion: self = .dataQuality
        case .warning: self = .stakeholder
        }
    }
}
