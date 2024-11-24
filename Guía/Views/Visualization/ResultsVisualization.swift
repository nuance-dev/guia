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
                radarChartBackground
                
                ForEach(results.rankedOptions) { option in
                    RadarShape(points: calculateRadarPoints(for: option))
                        .fill(Color.accentColor.opacity(0.1))
                        .overlay(
                            RadarShape(points: calculateRadarPoints(for: option))
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
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
        let center = CGPoint(x: 150, y: 150)
        let radius: CGFloat = 130
        let criteriaCount = results.criteria.count
        
        guard criteriaCount > 0 else { return [] }
        
        return results.criteria.enumerated().map { index, criterion in
            let angle = (2 * .pi * Double(index) / Double(criteriaCount)) - (.pi / 2)
            let score = option.breakdownByCriteria[criterion.id] ?? 0
            
            let x = center.x + radius * CGFloat(score) * cos(angle)
            let y = center.y + radius * CGFloat(score) * sin(angle)
            
            return CGPoint(x: x, y: y)
        }
    }
    
    private var radarChartBackground: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
            let radius: CGFloat = min(geometry.size.width, geometry.size.height)/2 - 20
            let criteriaCount = results.criteria.count
            
            ZStack {
                ForEach(0..<criteriaCount, id: \.self) { index in
                    let angle = (2 * .pi * Double(index) / Double(criteriaCount)) - (.pi / 2)
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: CGPoint(
                            x: center.x + radius * cos(angle),
                            y: center.y + radius * sin(angle)
                        ))
                    }
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    
                    Text(results.criteria[index].name)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .position(
                            x: center.x + (radius + 20) * cos(angle),
                            y: center.y + (radius + 20) * sin(angle)
                        )
                }
                
                ForEach(0..<5) { i in
                    Circle()
                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                        .frame(width: radius * 2 * CGFloat(i+1) / 5)
                }
            }
        }
    }
}

// Add RadarShape struct
struct RadarShape: Shape {
    let points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !points.isEmpty else { return path }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
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