import SwiftUI

struct FactorList: View {
    @Binding var option: Option
    @State private var newFactor: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Key Factors")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            ForEach($option.factors) { $factor in
                HStack(spacing: 16) {
                    Text(factor.name)
                        .foregroundColor(.white)
                    
                    Slider(value: $factor.weight, in: 0...1)
                        .tint(.white.opacity(0.6))
                    
                    Text("\(Int(factor.weight * 100))%")
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 40)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .background(Color.white.opacity(0.03))
                .cornerRadius(8)
            }
            
            HStack {
                TextField("Add a factor", text: $newFactor)
                    .textFieldStyle(.plain)
                    .foregroundColor(.white)
                
                Button(action: addFactor) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func addFactor() {
        guard !newFactor.isEmpty else { return }
        option.factors.append(Factor(name: newFactor, weight: 0.5, score: 0))
        newFactor = ""
    }
} 