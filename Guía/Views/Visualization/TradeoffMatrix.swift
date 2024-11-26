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
            
            chartSection
            criteriaSelection
        }
        .onAppear {
            initializeSelectedCriteria()
        }
    }
    
    private func initializeSelectedCriteria() {
        // Initially select first 3 criteria
        selectedCriteria = Set(decision.criteria.prefix(3).map { $0.id })
    }
    
    private var chartSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            tradeoffChart
                .chartYScale(domain: 0...1)
                .frame(width: calculateChartWidth())
                .frame(height: 300)
        }
    }
    
    private func calculateChartWidth() -> CGFloat {
        max(300, CGFloat(selectedCriteria.count * 100))
    }
    
    private var tradeoffChart: some View {
        Chart {
            ForEach(results.rankedOptions) { option in
                ForEach(selectedCriteriaArray) { criterion in
                    LineMark(
                        x: .value("Criterion", criterion.name),
                        y: .value("Score", option.breakdownByCriteria[criterion.id] ?? 0)
                    )
                    .foregroundStyle(by: .value("Option", getOptionName(for: option.optionId)))
                    .symbol(by: .value("Option", getOptionName(for: option.optionId)))
                }
            }
        }
    }
    
    private func getOptionName(for id: UUID) -> String {
        decision.options.first { $0.id == id }?.title ?? "Unknown Option"
    }
    
    private var criteriaSelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(decision.criteria) { criterion in
                    criterionToggle(for: criterion)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func criterionToggle(for criterion: any Criterion) -> some View {
        Toggle(criterion.name, isOn: createCriterionBinding(for: criterion))
            .toggleStyle(.button)
            .buttonStyle(.bordered)
    }
    
    private func createCriterionBinding(for criterion: any Criterion) -> Binding<Bool> {
        Binding(
            get: { selectedCriteria.contains(criterion.id) },
            set: { isSelected in
                if isSelected {
                    selectedCriteria.insert(criterion.id)
                } else {
                    selectedCriteria.remove(criterion.id)
                }
            }
        )
    }
    
    private var selectedCriteriaArray: [any Criterion] {
        decision.criteria.filter { selectedCriteria.contains($0.id) }
    }
} 
