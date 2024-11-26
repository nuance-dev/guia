import SwiftUI

struct WeightsView: View {
    @ObservedObject var viewModel: DecisionViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Criteria Weights")
                    .font(.headline)
                
                Spacer()
            }
            
            if viewModel.decision.criteria.isEmpty {
                ContentUnavailableView(
                    "No Criteria Added",
                    systemImage: "scale.3d",
                    description: Text("Add criteria before assigning weights")
                )
            } else {
                List {
                    ForEach(viewModel.decision.criteria) { criterion in
                        CriterionWeightRow(
                            criterion: criterion,
                            weight: Binding(
                                get: { viewModel.decision.weights[criterion.id] ?? 1.0 },
                                set: { newValue in
                                    Task {
                                        try? await viewModel.updateWeight(for: criterion, to: newValue)
                                    }
                                }
                            )
                        )
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct CriterionWeightRow: View {
    let criterion: any Criterion
    @Binding var weight: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(criterion.name)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.0f%%", weight * 100))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $weight, in: 0...1, step: 0.1)
                .tint(.primary)
        }
        .padding(.vertical, 4)
    }
} 