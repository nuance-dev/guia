import SwiftUI

struct ContentView: View {
    @State private var decisions: [Decision] = []
    @State private var showingNewDecisionSheet = false
    
    private let maxDecisions = 3
    
    var body: some View {
        NavigationView {
            mainContent
                .frame(minWidth: 600, minHeight: 400)
                .navigationTitle("Decisions")
                .toolbar { toolbarContent }
        }
        .sheet(isPresented: $showingNewDecisionSheet) {
            NewDecisionSheet { decision in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    decisions.append(decision)
                }
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if decisions.isEmpty {
            EmptyStateView(onAddDecision: { showingNewDecisionSheet = true })
        } else {
            decisionGridView
        }
    }
    
    private var decisionGridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 300, maximum: .infinity))],
                spacing: 24
            ) {
                decisionCards
                addDecisionButton
            }
            .padding(24)
        }
    }
    
    @ViewBuilder
    private var decisionCards: some View {
        ForEach(decisions) { decision in
            DecisionCard(decision: decision)
        }
    }
    
    @ViewBuilder
    private var addDecisionButton: some View {
        if decisions.count < maxDecisions {
            AddDecisionCard(onClick: { showingNewDecisionSheet = true })
        }
    }
    
    @ViewBuilder
    private var toolbarContent: some View {
        if !decisions.isEmpty && decisions.count < maxDecisions {
            Button(action: { showingNewDecisionSheet = true }) {
                Label("New Decision", systemImage: "plus")
            }
        }
    }
}

struct AddDecisionCard: View {
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16, weight: .light))
                Text("Add Another Decision")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.secondary)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
