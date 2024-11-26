import SwiftUI

struct WeightingView: View {
    @Binding var factors: [Factor]
    @State private var hoveredFactor: Factor?
    @EnvironmentObject private var decisionContext: DecisionContext
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
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
            
            // Context section
            if !decisionContext.options.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ForEach(decisionContext.options) { option in
                            Text(option.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.03))
                                .cornerRadius(16)
                        }
                    }
                }
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
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 48, alignment: .trailing)
                        }
                        
                        // Weight slider
                        Slider(value: $factor.weight, in: 0...1, step: 0.1)
                            .tint(.white.opacity(0.6))
                        
                        // Weight indicator
                        HStack(spacing: 2) {
                            ForEach(0..<10) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(
                                        Double(index) / 10 <= factor.weight ? 0.6 : 0.1
                                    ))
                                    .frame(height: 4)
                            }
                        }
                    }
                    .padding(20)
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
            
            Spacer()
            
            // Help tip
            ContextualHelpView(tip: "Adjust the sliders to reflect how important each factor is in your decision.")
        }
        .onChange(of: factors) { _, newFactors in
            // Enable progress when all factors have been weighted
            flowManager.updateProgressibility(newFactors.allSatisfy { $0.weight > 0 })
        }
    }
} 