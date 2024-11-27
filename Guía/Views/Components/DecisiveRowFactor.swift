import SwiftUI

struct DecisiveRowFactor: View {
    let factor: Factor
    let options: [Option]
    @State private var isExpanded = false
    @State private var isHovered = false
    
    private var impactScore: Double {
        factor.weight * factor.normalizedScore
    }
    
    private var scoreVariance: Double {
        let scores = options.compactMap { option in
            option.scores[factor.id]
        }
        guard scores.count >= 2 else { return 0 }
        return abs(scores.max()! - scores.min()!)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row
            HStack(spacing: 16) {
                // Impact indicator
                Circle()
                    .fill(Color.accentColor.opacity(impactScore > 0.6 ? 1 : 0.5))
                    .frame(width: 8, height: 8)
                    .opacity(isHovered ? 1 : 0.7)
                
                // Factor name and weight
                VStack(alignment: .leading, spacing: 4) {
                    Text(factor.name)
                        .font(.system(size: 14, weight: .medium))
                    Text("\(Int(factor.weight * 100))% weight")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Impact visualization
                HStack(spacing: 8) {
                    // Score variance indicator
                    ProgressView(value: scoreVariance, total: 2)
                        .progressViewStyle(.linear)
                        .frame(width: 60)
                        .tint(Color.accentColor)
                    
                    // Expand button
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(isHovered ? 0.05 : 0.02))
            .cornerRadius(8)
            
            // Expanded details
            if isExpanded {
                VStack(spacing: 16) {
                    // Option comparisons
                    ForEach(options) { option in
                        if let score = option.scores[factor.id] {
                            HStack(spacing: 12) {
                                Text(option.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                ScoreIndicator(score: score)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.02))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}
