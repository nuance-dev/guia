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
                                    viewModel.decision.weights[criterion.id] = newValue
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