import SwiftUI


struct StakeholderView: View {
    let decision: Decision
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stakeholder Analysis")
                .font(.headline)
                .padding(.bottom, 8)
            
            if let stakeholders = decision.cognitiveContext?.stakeholderImpact, !stakeholders.isEmpty {
                ForEach(stakeholders, id: \.stakeholder) { stakeholder in
                    StakeholderCard(stakeholder: stakeholder)
                }
            } else {
                ContentEmptyStateView(
                    title: "No Stakeholders Added",
                    message: "Add stakeholders to analyze their impact on your decision.",
                    systemImage: "person.2.slash"
                )
            }
        }
        .padding()
    }
}

struct StakeholderCard: View {
    let stakeholder: CognitiveFramework.StakeholderImpact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stakeholder.stakeholder)
                .font(.headline)
            
            HStack {
                Label("Impact", systemImage: "arrow.up.arrow.down")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f", stakeholder.impact))
            }
            
            HStack {
                Label("Influence", systemImage: "chart.bar")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f", stakeholder.influence))
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}