import SwiftUI
import Charts

struct ResultsVisualization: View {
    // MARK: - Properties
    let results: AnalysisResults
    @State private var selectedVisualization: VisualizationType = .barChart
    
    enum VisualizationType {
        case barChart
        case radarChart
        case sensitivityMatrix
        
        var label: String {
            switch self {
            case .barChart: return "Ranking"
            case .radarChart: return "Criteria"
            case .sensitivityMatrix: return "Sensitivity"
            }
        }
        
        var icon: String {
            switch self {
            case .barChart: return "chart.bar"
            case .radarChart: return "chart.dots.scatter"
            case .sensitivityMatrix: return "chart.xyaxis.line"
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            visualizationPicker
            
            switch selectedVisualization {
            case .barChart:
                RankedOptionsChart(results: results)
            case .radarChart:
                CriteriaRadarChart(results: results)
            case .sensitivityMatrix:
                SensitivityMatrixView(results: results)
            }
        }
        .animation(.spring(), value: selectedVisualization)
    }
    
    // MARK: - Supporting Views
    private var visualizationPicker: some View {
        Picker("Visualization", selection: $selectedVisualization) {
            ForEach([VisualizationType.barChart, .radarChart, .sensitivityMatrix], id: \.self) { type in
                Label(type.label, systemImage: type.icon)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .labelStyle(.iconOnly)
    }
}

// MARK: - Ranked Options Chart
private struct RankedOptionsChart: View {
    let results: AnalysisResults
    
    var body: some View {
        Chart {
            ForEach(results.rankedOptions) { option in
                BarMark(
                    x: .value("Score", option.score),
                    y: .value("Rank", option.rank)
                )
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .annotation(position: .trailing) {
                    Text(String(format: "%.2f", option.score))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Criteria Radar Chart
private struct CriteriaRadarChart: View {
    let results: AnalysisResults
    @State private var selectedOption: AnalysisResults.RankedOption?
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(results.rankedOptions) { option in
                    Path { path in
                        let points = calculateRadarPoints(for: option)
                        for (index, point) in points.enumerated() {
                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                        path.closeSubpath()
                    }
                    .fill(Color.accentColor.opacity(0.1))
                    .stroke(Color.accentColor, lineWidth: 1)
                    .opacity(selectedOption == nil || selectedOption?.id == option.id ? 1 : 0.2)
                }
            }
            .frame(height: 300)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in selectedOption = nil }
            )
            
            // Legend
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(results.rankedOptions) { option in
                        Button {
                            withAnimation {
                                selectedOption = selectedOption?.id == option.id ? nil : option
                            }
                        } label: {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.accentColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func calculateRadarPoints(for option: AnalysisResults.RankedOption) -> [CGPoint] {
        // Implementation for calculating radar chart points
        // This would convert the option's criteria scores into points on a radar/spider chart
        []  // Placeholder - actual implementation would return array of CGPoints
    }
}

// MARK: - Sensitivity Matrix View
private struct SensitivityMatrixView: View {
    let results: AnalysisResults
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sensitivity Analysis")
                .font(.headline)
            
            if let sensitivityData = results.sensitivityData {
                VStack(spacing: 24) {
                    // Stability Index
                    HStack {
                        Text("Stability Index")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", sensitivityData.stabilityIndex * 100))
                            .monospacedDigit()
                    }
                    
                    // Critical Criteria
                    if !sensitivityData.criticalCriteria.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Critical Criteria")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(sensitivityData.criticalCriteria, id: \.self) { criterionId in
                                if let sensitivity = sensitivityData.weightSensitivity[criterionId] {
                                    HStack {
                                        Text(criterionId.uuidString) // Replace with actual criterion name
                                        Spacer()
                                        Text(String(format: "%.2f", sensitivity))
                                            .monospacedDigit()
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No sensitivity data available")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}