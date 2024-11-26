import SwiftUI

struct HeaderView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Decision Guide")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                ConfidenceIndicator(value: progress)
                    .frame(width: 100, height: 4)
            }
            .frame(height: 44)
        }
    }
} 