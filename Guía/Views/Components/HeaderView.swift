import SwiftUI

struct HeaderView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 2)
                }
            }
            .frame(height: 2)
            .padding(.bottom, 20)
            
            // Step indicators
            HStack(spacing: 0) {
                ForEach(Step.allCases, id: \.self) { step in
                    let stepProgress = step.progressValue
                    let isActive = progress >= stepProgress
                    
                    VStack(spacing: 8) {
                        Text(step.title)
                            .font(.system(size: 13, weight: isActive ? .medium : .regular))
                            .foregroundStyle(isActive ? .primary : .secondary)
                            .opacity(isActive ? 1 : 0.6)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

enum Step: Int, CaseIterable {
    case initial
    case optionEntry
    case factorCollection
    case weighting
    case scoring
    case analysis
    
    var title: String {
        switch self {
        case .initial: return "Start"
        case .optionEntry: return "Options"
        case .factorCollection: return "Factors"
        case .weighting: return "Weight"
        case .scoring: return "Score"
        case .analysis: return "Analysis"
        }
    }
    
    var progressValue: Double {
        Double(rawValue) / Double(Step.allCases.count - 1)
    }
} 