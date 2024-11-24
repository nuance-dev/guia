import SwiftUI

struct CriteriaMatrix: View {
    // MARK: - Properties
    @Binding var criteria: [Criterion]
    @Binding var pairwiseComparisons: [[Double]]
    @Environment(\.isAdvancedMode) var isAdvancedMode
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isAdvancedMode {
                ahpMatrixView
            } else {
                simpleWeightView
            }
        }
    }
    
    // MARK: - Private Views
    private var ahpMatrixView: some View {
        Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 8) {
            // TODO: Implement AHP pairwise comparison matrix
            // This is where users can compare criteria importance
        }
    }
    
    private var simpleWeightView: some View {
        VStack(spacing: 12) {
            ForEach(criteria) { criterion in
                CriterionWeightRow(criterion: criterion)
            }
        }
    }
}