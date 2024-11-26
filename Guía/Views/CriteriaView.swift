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
                        VStack(alignment: .leading, spacing: 4) {
                            Text(criterion.name)
                                .font(.headline)
                            
                            if let description = criterion.description {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let unit = criterion.unit {
                                Text("Unit: \(unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Label(
                                    criterion.importance.rawValue.capitalized,
                                    systemImage: importanceIcon(for: criterion.importance)
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingCriterionSheet) {
            NavigationStack {
                CriterionEditView { criterion in
                    viewModel.addCriterion(criterion)
                }
            }
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