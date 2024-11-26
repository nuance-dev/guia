import SwiftUI

struct TimeframeComparison: View {
    let firstOption: Option
    let secondOption: Option
    
    private let timeframes = TimeFrame.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Timeline Impact")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            timelineView
        }
    }
    
    private var timelineView: some View {
        HStack(spacing: 0) {
            ForEach(timeframes, id: \.self) { timeframe in
                VStack(spacing: 8) {
                    timeframeIndicator(timeframe)
                    Text(timeframe.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
    
    private func timeframeIndicator(_ timeframe: TimeFrame) -> some View {
        HStack(spacing: 4) {
            if firstOption.timeframe == timeframe {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
            }
            if secondOption.timeframe == timeframe {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 8, height: 8)
            }
        }
        .frame(height: 20)
    }
} 