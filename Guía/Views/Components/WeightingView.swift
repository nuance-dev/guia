import SwiftUI

struct WeightingView: View {
    @Binding var factors: [Factor]
    @State private var hoveredFactor: Factor?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight Your Factors")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Adjust how important each factor is to your decision")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Factors list
            VStack(spacing: 20) {
                ForEach($factors) { $factor in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(factor.name)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f%%", factor.weight * 100))
                                .foregroundColor(.white.opacity(0.6))
                                .font(.system(.subheadline, design: .rounded))
                        }
                        
                        // Custom slider
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Track
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                // Fill
                                Rectangle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.accentColor.opacity(0.8),
                                            Color.accentColor
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: geometry.size.width * factor.weight, height: 4)
                                    .cornerRadius(2)
                                
                                // Thumb
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 16, height: 16)
                                    .offset(x: (geometry.size.width * factor.weight) - 8)
                                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            }
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newWeight = value.location.x / geometry.size.width
                                        factor.weight = min(max(newWeight, 0), 1)
                                    }
                            )
                        }
                        .frame(height: 16)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
} 