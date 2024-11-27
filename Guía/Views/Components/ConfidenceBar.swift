import SwiftUI

struct ConfidenceBar: View {
    let score: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: max(0, min(geometry.size.width, geometry.size.width * score)), height: 4)
                    .cornerRadius(2)
            }
        }
        .frame(height: 4)
    }
} 