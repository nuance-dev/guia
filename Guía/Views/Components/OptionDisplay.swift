import SwiftUI

struct OptionDisplay: View {
    let option: Option
    let isSelected: Bool
    let showScore: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Option name
            Text(option.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            
            if showScore {
                // Score indicator
                HStack(spacing: 8) {
                    ProgressView(value: option.confidenceScore, total: 1.0)
                        .tint(.white.opacity(0.8))
                    
                    Text("\(Int(option.confidenceScore * 100))%")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Metadata pills
            if !option.factors.isEmpty {
                HStack(spacing: 8) {
                    MetadataPill(text: "\(option.factors.count) factors")
                    MetadataPill(text: option.timeframe.rawValue)
                    MetadataPill(text: option.riskLevel.rawValue)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(isSelected ? 0.2 : 0.05), lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct MetadataPill: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(.white.opacity(0.5))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
    }
}

// Preview provider for development
struct OptionDisplay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                OptionDisplay(
                    option: Option(
                        name: "Stay at current job",
                        factors: [
                            Factor(name: "Stability", weight: 0.8, score: 0.9),
                            Factor(name: "Growth", weight: 0.6, score: 0.4)
                        ],
                        timeframe: .immediate,
                        riskLevel: .low
                    ),
                    isSelected: true,
                    showScore: true
                )
                
                OptionDisplay(
                    option: Option(
                        name: "Accept new offer",
                        factors: [
                            Factor(name: "Salary", weight: 0.9, score: 0.8),
                            Factor(name: "Location", weight: 0.7, score: 0.6)
                        ],
                        timeframe: .shortTerm,
                        riskLevel: .medium
                    ),
                    isSelected: false,
                    showScore: true
                )
            }
            .padding()
        }
    }
} 