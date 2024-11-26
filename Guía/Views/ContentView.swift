import SwiftUI

struct ContentView: View {
    @State private var decisions: [Decision] = []
    @State private var showingNewDecisionSheet = false
    @State private var selectedDecision: Decision?
    
    private let maxDecisions = 3
    
    var body: some View {
        NavigationSplitView {
            List(decisions, selection: $selectedDecision) { decision in
                DecisionRow(decision: decision)
                    .tag(decision)
            }
            .navigationTitle("Decisions")
            .toolbar {
                if decisions.count < maxDecisions {
                    Button(action: { showingNewDecisionSheet = true }) {
                        Label("New Decision", systemImage: "plus")
                    }
                }
            }
            .overlay {
                if decisions.isEmpty {
                    EmptyStateView(onAddDecision: { showingNewDecisionSheet = true })
                }
            }
        } detail: {
            if let decision = selectedDecision {
                DecisionDetailView(decision: decision)
            } else {
                ContentUnavailableView(
                    "No Decision Selected",
                    systemImage: "arrow.left",
                    description: Text("Select a decision from the sidebar to view its details")
                )
            }
        }
        .sheet(isPresented: $showingNewDecisionSheet) {
            NewDecisionSheet { decision in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    decisions.append(decision)
                    selectedDecision = decision
                }
            }
        }
    }
}

struct DecisionRow: View {
    let decision: Decision
    @StateObject private var viewModel: DecisionViewModel
    
    init(decision: Decision) {
        self.decision = decision
        self._viewModel = StateObject(wrappedValue: DecisionViewModel(decision: decision))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(decision.title)
                .font(.headline)
            
            if let description = decision.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            ProgressView(value: viewModel.completionProgress)
                .progressViewStyle(.linear)
                .tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
