import SwiftUI
import Charts

struct SensitivityAnalysis: View {
    // MARK: - Properties
    let results: AnalysisResults
    @State private var selectedCriterion: Criterion?
    @State private var weightAdjustment: Double = 0
    @State private var showingCriticalCriteriaInfo = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            sensitivityChart
            
            if let selectedCriterion = selectedCriterion {
                weightAdjustmentSlider(for: selectedCriterion)
            }
            
            impactAnalysis
        }
        .padding()
    }
    
    // MARK: - Private Views
    private var sensitivityChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sensitivity Analysis")
                .font(.headline)
            
            SensitivityBarChart(sensitivityData: results.sensitivityData.weightSensitivity)
        }
    }
    
    private func weightAdjustmentSlider(for criterion: Criterion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight Adjustment for \(criterion.name)")
                .font(.subheadline)
            
            HStack {
                Text("-20%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $weightAdjustment, in: -0.2...0.2, step: 0.01)
                    .onChange(of: weightAdjustment) { oldValue, newValue in
                        // Update analysis with new weight
                        // This would trigger a recalculation in a real implementation
                    }
                
                Text("+20%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let switchingPoint = results.sensitivityData.switchingPoints.first(where: { $0.criterionId == criterion.id }) {
                Text("Switching point at \(Int(switchingPoint.switchingWeight * 100))% weight")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var impactAnalysis: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Critical Criteria")
                    .font(.headline)
                
                Button {
                    showingCriticalCriteriaInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
                .popover(isPresented: $showingCriticalCriteriaInfo) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Critical criteria are those whose weight changes could significantly affect the final decision.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: 250)
                            .padding()
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(results.sensitivityData.criticalCriteria, id: \.self) { criterionId in
                        CriticalCriterionCard(
                            criterion: criterionId,
                            sensitivity: results.sensitivityData.weightSensitivity[criterionId] ?? 0
                        )
                    }
                }
            }
            
            StabilityIndicator(stabilityIndex: results.sensitivityData.stabilityIndex)
        }
    }
}

// MARK: - Supporting Views
private struct CriticalCriterionCard: View {
    let criterion: UUID
    let sensitivity: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(criterion.uuidString.prefix(8))
                .font(.subheadline)
                .bold()
            
            Text("Sensitivity: \(String(format: "%.2f", sensitivity))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

private struct StabilityIndicator: View {
    let stabilityIndex: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Decision Stability")
                .font(.subheadline)
            
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.red, .orange, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Text(String(format: "%.0f%%", stabilityIndex * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(stabilityDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var stabilityDescription: String {
        switch stabilityIndex {
        case 0.8...1.0:
            return "Very stable decision"
        case 0.6..<0.8:
            return "Moderately stable decision"
        case 0.4..<0.6:
            return "Somewhat sensitive to changes"
        default:
            return "Highly sensitive to changes"
        }
    }
}

private struct SensitivityBarChart: View {
    let sensitivityData: [UUID: Double]
    
    var body: some View {
        Chart(prepareChartData(), id: \.key) { item in
            BarMark(
                x: .value("Criterion", String(item.key.uuidString.prefix(8))),
                y: .value("Sensitivity", item.value)
            )
            .foregroundStyle(getSensitivityColor(item.value))
        }
        .frame(height: 200)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks {
                AxisValueLabel()
                    .offset(y: 10)
            }
        }
    }
    
    private func getSensitivityColor(_ value: Double) -> Color {
        switch value {
        case 0.8...: return .red.opacity(0.7)
        case 0.5..<0.8: return .orange.opacity(0.7)
        default: return .green.opacity(0.7)
        }
    }
    
    private func prepareChartData() -> [(key: UUID, value: Double)] {
        sensitivityData.sorted { $0.value > $1.value }
    }
}

#Preview {
    SensitivityAnalysis(
        results: AnalysisResults(
            rankedOptions: [],
            confidenceScore: 0.85,
            sensitivityData: SensitivityData(
                weightSensitivity: [:],
                scoreSensitivity: [:],
                stabilityIndex: 0.75,
                criticalCriteria: [],
                switchingPoints: []
            ),
            method: .ahp,
            criteria: []
        )
    )
}