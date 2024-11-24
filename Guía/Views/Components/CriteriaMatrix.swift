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
        ScrollView([.horizontal, .vertical]) {
            Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 8) {
                // Header Row
                GridRow {
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    ForEach(criteria) { criterion in
                        Text(criterion.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(-45))
                            .frame(width: 60)
                    }
                }
                
                // Matrix Rows
                ForEach(Array(criteria.enumerated()), id: \.element.id) { i, rowCriterion in
                    GridRow {
                        Text(rowCriterion.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        ForEach(Array(criteria.enumerated()), id: \.element.id) { j, _ in
                            ComparisonCell(
                                value: $pairwiseComparisons[i][j],
                                isEditable: i != j
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var simpleWeightView: some View {
        VStack(spacing: 12) {
            ForEach(criteria) { criterion in
                CriterionWeightRow(
                    criterion: criterion,
                    weight: binding(for: criterion)
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func binding(for criterion: Criterion) -> Binding<Double> {
        guard let index = criteria.firstIndex(where: { $0.id == criterion.id }) else {
            return .constant(0)
        }
        return $pairwiseComparisons[index][index]
    }
}

// MARK: - Supporting Views
struct ComparisonCell: View {
    @Binding var value: Double
    let isEditable: Bool
    
    var body: some View {
        if isEditable {
            Menu {
                ForEach([1, 3, 5, 7, 9], id: \.self) { intensity in
                    Button("Equal importance") { value = Double(intensity) }
                }
            } label: {
                Text(String(format: "%.1f", value))
                    .font(.caption)
                    .frame(width: 60)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(6)
            }
            .disabled(!isEditable)
        } else {
            Text("1.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60)
        }
    }
}

struct CriterionWeightRow: View {
    let criterion: Criterion
    @Binding var weight: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(criterion.name)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            HStack {
                Slider(value: $weight, in: 0...1)
                    .frame(maxWidth: .infinity)
                
                Text(String(format: "%.2f", weight))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}