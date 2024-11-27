import SwiftUI

struct OptionSummaryCard: View {
    let option: Option
    let isSelected: Bool
    let isBest: Bool
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with option name and status
            HStack(spacing: 12) {
                Text(option.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isBest ? .accentColor : .white)
                
                if isBest {
                    Label("Recommended", systemImage: "star.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Spacer()
                
                // Confidence score
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Confidence")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(Int(option.confidenceScore))%")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.accentColor)
                }
            }
            
            // Key metrics
            HStack(spacing: 24) {
                metricBadge(
                    icon: "clock",
                    label: option.timeframe.rawValue
                )
                metricBadge(
                    icon: "chart.line.uptrend.xyaxis",
                    label: option.riskLevel.rawValue
                )
                metricBadge(
                    icon: "number",
                    label: "\(option.factors.count) factors"
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isHovered || isSelected ? 0.08 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isBest ? Color.accentColor.opacity(0.3) : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
    
    private func metricBadge(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(label)
                .font(.system(size: 13))
        }
        .foregroundColor(.white.opacity(0.6))
    }
}