import SwiftUI

struct ContentView: View {
    @StateObject private var decisionVM = DecisionViewModel(
        decision: Decision(
            title: "New Decision",
            description: "Make a better choice"
        )
    )
    @State private var selectedTab = Tab.options
    @State private var showingNewOptionSheet = false
    @State private var showingNewCriterionSheet = false
    
    enum Tab {
        case options
        case criteria
        case analysis
        
        var title: String {
            switch self {
            case .options: return "Options"
            case .criteria: return "Criteria"
            case .analysis: return "Analysis"
            }
        }
        
        var icon: String {
            switch self {
            case .options: return "list.bullet"
            case .criteria: return "slider.horizontal.3"
            case .analysis: return "chart.bar"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            sidebar
            
            mainContent
        }
        .frame(minWidth: 800, minHeight: 500)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                HStack(spacing: 16) {
                    Button {
                        showingNewOptionSheet = true
                    } label: {
                        Label("New Option", systemImage: "plus.circle")
                    }
                    
                    Button {
                        showingNewCriterionSheet = true
                    } label: {
                        Label("New Criterion", systemImage: "plus.square")
                    }
                    
                    Button {
                        analyze()
                    } label: {
                        Label("Analyze", systemImage: "chart.line.uptrend.xyaxis")
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .sheet(isPresented: $showingNewOptionSheet) {
            OptionEditView(mode: .add) { option in
                Task {
                    try? await decisionVM.addOption(option)
                }
            }
        }
        .sheet(isPresented: $showingNewCriterionSheet) {
            CriterionEditView { criterion in
                Task {
                    try? await decisionVM.addCriterion(criterion)
                }
            }
        }
    }
    
    private var sidebar: some View {
        List(selection: $selectedTab) {
            NavigationLink(value: Tab.options) {
                Label("Options", systemImage: Tab.options.icon)
            }
            
            NavigationLink(value: Tab.criteria) {
                Label("Criteria", systemImage: Tab.criteria.icon)
            }
            
            NavigationLink(value: Tab.analysis) {
                Label("Analysis", systemImage: Tab.analysis.icon)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200, maxWidth: 250)
    }
    
    private var mainContent: some View {
        NavigationStack {
            Group {
                switch selectedTab {
                case .options:
                    OptionListView(options: .init(
                        get: { decisionVM.decision.options },
                        set: { newOptions in
                            Task {
                                for option in newOptions {
                                    try? await decisionVM.updateOption(option)
                                }
                            }
                        }
                    ))
                    
                case .criteria:
                    CriteriaMatrix(
                        criteria: .init(
                            get: { decisionVM.decision.criteria },
                            set: { newCriteria in
                                Task {
                                    for criterion in newCriteria {
                                        try? await decisionVM.updateCriterion(criterion)
                                    }
                                }
                            }
                        ),
                        pairwiseComparisons: .init(
                            get: { decisionVM.decision.pairwiseComparisons ?? [] },
                            set: { comparisons in
                                Task {
                                    try? await decisionVM.updatePairwiseComparisons(comparisons)
                                }
                            }
                        )
                    )
                    
                case .analysis:
                    if let results = decisionVM.decision.analysisResults {
                        ResultsVisualization(results: results)
                    } else {
                        EmptyAnalysisView()
                    }
                }
            }
        }
    }
    
    private func analyze() {
        Task {
            try? await decisionVM.performAnalysis()
        }
    }
}

#Preview {
    ContentView()
}
