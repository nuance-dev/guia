import SwiftUI

struct ScoreIndicator: View {
    let score: Double
    let weight: Double?
    let showLabel: Bool
    let style: ScoreIndicatorStyle
    
    init(
        score: Double,
        weight: Double? = nil,
        showLabel: Bool = true,
        style: ScoreIndicatorStyle = .compact
    ) {
        self.score = score
        self.weight = weight
        self.showLabel = showLabel
        self.style = style
    }
    
    private var scoreColor: Color {
        switch score {
        case 0.7...: return .green
        case 0.4..<0.7: return .yellow
        default: return .red
        }
    }
    
    var body: some View {
        switch style {
        case .compact:
            compactView
        case .detailed:
            detailedView
        case .minimal:
            minimalView
        }
    }
    
    private var compactView: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(scoreColor.opacity(0.8))
                .frame(width: 8, height: 8)
            
            if showLabel {
                Text("\(Int(score * 100))%")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private var detailedView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let weight {
                HStack {
                    Text("Weight:")
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(Int(weight * 100))%")
                        .foregroundColor(.white)
                }
                .font(.system(size: 12))
            }
            
            HStack {
                Text("Score:")
                    .foregroundColor(.white.opacity(0.6))
                Text("\(Int(score * 100))%")
                    .foregroundColor(scoreColor)
            }
            .font(.system(size: 12))
            
            // Score bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(scoreColor)
                        .frame(width: geometry.size.width * score)
                        .frame(height: 4)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
        }
    }
    
    private var minimalView: some View {
        Circle()
            .fill(scoreColor.opacity(0.8))
            .frame(width: 6, height: 6)
    }
}

enum ScoreIndicatorStyle {
    case compact
    case detailed
    case minimal
}