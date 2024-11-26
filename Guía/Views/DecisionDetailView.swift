import SwiftUI

struct DecisionDetailView: View {
    let decision: Decision
    @StateObject private var viewModel: DecisionViewModel
    @State private var selectedStage: DecisionStage = .problem
    
    init(decision: Decision) {
        self.decision = decision
        self._viewModel = StateObject(wrappedValue: DecisionViewModel(decision: decision))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding()
                .background(.background)
            
            Divider()
            
            // Stage Navigation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(DecisionStage.allCases, id: \.self) { stage in
                        StageButton(
                            stage: stage,
                            isSelected: stage == selectedStage,
                            isCompleted: viewModel.isStageCompleted(stage),
                            action: { selectedStage = stage }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(.background)
            
            Divider()
            
            // Content
            ScrollView {
                stageContent
                    .padding()
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(decision.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let description = decision.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let primaryInsight = viewModel.primaryInsight {
                InsightBadge(insight: primaryInsight)
                    .padding(.top, 4)
            }
        }
    }
    
    @ViewBuilder
    private var stageContent: some View {
        switch selectedStage {
        case .problem:
            ProblemDefinitionView(viewModel: viewModel)
        case .stakeholders:
            StakeholderView(decision: decision)
        case .options:
            OptionsView(viewModel: viewModel)
        case .criteria:
            CriteriaView(viewModel: viewModel)
        case .weights:
            WeightsView(viewModel: viewModel)
        case .analysis:
            AnalysisView(viewModel: viewModel)
        case .refinement:
            RefinementView(viewModel: viewModel)
        case .validation:
            ValidationView(viewModel: viewModel)
        }
    }
}