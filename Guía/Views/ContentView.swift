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
            ToolbarItemGroup {
                ButtonGroup(buttons: [
                    ("New Option", "plus.circle", { showingNewOptionSheet = true }),
                    ("New Criterion", "plus.square", { showingNewCriterionSheet = true }),
                    ("Analyze", "chart.line.uptrend.xyaxis", analyze)
                ])
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
        Group {
            switch selectedTab {
            case .options:
                OptionListView(options: .constant(decisionVM.decision.options))
                    .navigationTitle("Options")
            case .criteria:
                CriteriaMatrix(
                    criteria: .constant(decisionVM.decision.criteria),
                    pairwiseComparisons: .constant([[1.0]])
                )
                .navigationTitle("Criteria")
            case .analysis:
                if let results = decisionVM.decision.analysisResults {
                    ResultsVisualization(results: results)
                        .navigationTitle("Analysis")
                } else {
                    ContentUnavailableView(
                        "No Analysis Available",
                        systemImage: "chart.bar",
                        description: Text("Run analysis to see results")
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VisualEffectBlur(material: .contentBackground, blendingMode: .behindWindow))
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
