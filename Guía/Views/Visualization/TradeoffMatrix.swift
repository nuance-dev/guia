import SwiftUI
import Charts

struct TradeoffMatrix: View {
    let decision: Decision
    let results: AnalysisResults
    
    @State private var selectedCriteria: Set<UUID> = []
    @State private var hoveredOption: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trade-off Analysis")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                Chart {
                    ForEach(results.rankedOptions) { option in
                        ForEach(decision.criteria.filter { selectedCriteria.contains($0.id) }) { criterion in
                            LineMark(
                                x: .value("Criterion", criterion.name),
                                y: .value("Score", 
                                    option.breakdownByCriteria[criterion.id] ?? 0
                                )
                            )
                            .foregroundStyle(by: .value("Option", option.optionId))
                            .symbol(by: .value("Option", option.optionId))
                        }
                    }
                }
                .chartYScale(domain: 0...1)
                .frame(width: max(300, CGFloat(selectedCriteria.count * 100)))
                .frame(height: 300)
            }
            
            // Criteria Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(decision.criteria) { criterion in
                        Toggle(criterion.name, isOn: Binding(
                            get: { selectedCriteria.contains(criterion.id) },
                            set: { isSelected in
                                if isSelected {
                                    selectedCriteria.insert(criterion.id)
                                } else {
                                    selectedCriteria.remove(criterion.id)
                                }
                            }
                        ))
                        .toggleStyle(.button)
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // Initially select first 3 criteria
            selectedCriteria = Set(decision.criteria.prefix(3).map { $0.id })
        }
    }
} 