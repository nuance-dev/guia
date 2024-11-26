import SwiftUI

struct CriteriaView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @State private var showingCriterionSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Decision Criteria")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingCriterionSheet = true }) {
                    Label("Add Criterion", systemImage: "plus")
                }
            }
            
            if viewModel.decision.criteria.isEmpty {
                ContentUnavailableView(
                    "No Criteria Added",
                    systemImage: "list.bullet",
                    description: Text("Add criteria to evaluate your options against")
                )
            } else {
                List {
                    ForEach(viewModel.decision.criteria) { criterion in
                        CriterionRow(criterion: criterion)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingCriterionSheet) {
            NavigationStack {
                CriterionEditView { criterion in
                    Task {
                        try? await viewModel.addCriterion(criterion)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct CriterionRow: View {
    let criterion: any Criterion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(criterion.name)
                .font(.headline)
            
            if let description = criterion.description {
                Text(description)
                    .font(.subheadline)
            }
            
            if let unifiedCriterion = criterion as? UnifiedCriterion {
                if let unit = unifiedCriterion.unit {
                    Text("Unit: \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(
                        importanceText(for: unifiedCriterion.importance),
                        systemImage: importanceIcon(for: unifiedCriterion.importance)
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            } else if let basicCriterion = criterion as? BasicCriterion {
                if let unit = basicCriterion.unit {
                    Text("Unit: \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(
                        importanceText(for: basicCriterion.importance),
                        systemImage: importanceIcon(for: basicCriterion.importance)
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func importanceText(for importance: UnifiedCriterion.Importance) -> String {
        switch importance {
        case .low: return "Low Importance"
        case .medium: return "Medium Importance"
        case .high: return "High Importance"
        }
    }
    
    private func importanceIcon(for importance: UnifiedCriterion.Importance) -> String {
        switch importance {
        case .low: return "arrow.down.circle"
        case .medium: return "circle"
        case .high: return "arrow.up.circle"
        }
    }
    
    private func importanceText(for importance: BasicCriterion.Importance) -> String {
        switch importance {
        case .low: return "Low Importance"
        case .medium: return "Medium Importance"
        case .high: return "High Importance"
        }
    }
    
    private func importanceIcon(for importance: BasicCriterion.Importance) -> String {
        switch importance {
        case .low: return "arrow.down.circle"
        case .medium: return "circle"
        case .high: return "arrow.up.circle"
        }
    }
} 