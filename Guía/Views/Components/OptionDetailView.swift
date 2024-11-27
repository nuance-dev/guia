import SwiftUI

struct OptionDetailView: View {
    let option: Option
    let isRecommended: Bool
    @State private var isHovered = false
    @State private var selectedFactorId: UUID?
    
    private var sortedFactors: [Factor] {
        option.factors.sorted { $0.weightedImpact > $1.weightedImpact }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header section
            headerSection
            
            // Metadata section
            metadataSection
            
            // Factors analysis
            factorsSection
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(isHovered ? 0.04 : 0.03))
                .animation(.easeInOut(duration: 0.2), value: isHovered)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isRecommended ? Color.accentColor.opacity(0.3) : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text(option.name)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isRecommended ? .accentColor : .white)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Confidence")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                Text("\(Int(option.confidenceScore))%")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private var metadataSection: some View {
        HStack(spacing: 16) {
            metadataItem(icon: "clock", text: option.timeframe.rawValue)
            metadataItem(icon: "chart.line.uptrend.xyaxis", text: option.riskLevel.rawValue)
            metadataItem(icon: "number", text: "\(option.factors.count) factors")
        }
    }
    
    private var factorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Factor Analysis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 12) {
                ForEach(sortedFactors) { factor in
                    FactorImpactRow(
                        factor: factor,
                        showWeight: true
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(selectedFactorId == factor.id ? 0.05 : 0.02))
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFactorId = selectedFactorId == factor.id ? nil : factor.id
                        }
                    }
                }
            }
        }
    }
    
    private func metadataItem(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13))
        }
        .foregroundColor(.white.opacity(0.6))
    }
}

struct MetadataItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13))
        }
        .foregroundColor(.white.opacity(0.6))
    }
}