import SwiftUI

struct DecisionMatrix: View {
    let firstOption: Option
    let secondOption: Option
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Decision Matrix")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 24) {
                optionColumn(option: firstOption)
                divider
                optionColumn(option: secondOption)
            }
            .padding(20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }
    
    private func optionColumn(option: Option) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(option.name)
                .font(.system(size: 16, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 12) {
                metricRow(label: "Score", value: String(format: "%.1f", option.weightedScore))
                metricRow(label: "Risk", value: option.riskLevel.rawValue)
                metricRow(label: "Timeframe", value: option.timeframe.rawValue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func metricRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 14, weight: .medium))
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1)
            .padding(.vertical, 8)
    }
} 