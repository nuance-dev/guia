import SwiftUI

struct WeightingView: View {
    @Binding var factors: [Factor]
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var selectedFactor: Factor.ID?
    @State private var showDistributionHint = false
    
    private var totalWeight: Double {
        factors.reduce(0) { $0 + $1.weight }
    }
    
    private var isBalanced: Bool {
        abs(totalWeight - 1.0) < 0.1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("How important is each factor?")
                    .font(.system(size: 32, weight: .medium))
                
                Text("Distribute 100 points across all factors")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Weight distribution indicator
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Weight Distribution")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("\(Int(totalWeight * 100))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isBalanced ? .green : .orange)
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 2) {
                        ForEach(factors) { factor in
                            Rectangle()
                                .fill(
                                    factor.id == selectedFactor 
                                    ? Color.accentColor 
                                    : Color.accentColor.opacity(0.6)
                                )
                                .frame(width: geometry.size.width * (factor.weight / max(totalWeight, 1)))
                        }
                    }
                }
                .frame(height: 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(2)
            }
            
            // Factors list
            VStack(spacing: 16) {
                ForEach($factors) { $factor in
                    WeightSlider(
                        factor: $factor,
                        isSelected: factor.id == selectedFactor,
                        onSelect: { selectedFactor = factor.id }
                    )
                }
            }
            
            // Help tip with animation
            if !isBalanced {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow.opacity(0.8))
                    Text("Try to distribute weights to total 100%")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(12)
                .background(Color.white.opacity(0.05))
                .cornerRadius(8)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: factors) { _, newFactors in
            flowManager.updateProgressibility(isBalanced)
        }
    }
}

struct WeightSlider: View {
    @Binding var factor: Factor
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(factor.name)
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Text("\(Int(factor.weight * 100))%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: 50, alignment: .trailing)
            }
            
            HStack(spacing: 16) {
                Slider(
                    value: $factor.weight,
                    in: 0...1,
                    step: 0.05
                )
                .tint(Color.accentColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isSelected ? 0.08 : 0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(isSelected ? 0.1 : 0.05), lineWidth: 1)
        )
        .onTapGesture(perform: onSelect)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
} 