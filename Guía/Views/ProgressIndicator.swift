import SwiftUI

struct ProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(progress))
            .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 24, height: 24)
    }
} 