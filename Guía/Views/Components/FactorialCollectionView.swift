import SwiftUI

struct FactorCollectionView: View {
    @Binding var factors: [Factor]
    @State private var newFactorName = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            Text("What factors matter most?")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
            
            Text("List the key aspects that will influence your decision")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.6))
            
            // Factors list
            VStack(spacing: 16) {
                ForEach($factors) { $factor in
                    HStack(spacing: 16) {
                        Text(factor.name)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Importance indicator
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { index in
                                Circle()
                                    .fill(index <= Int(factor.weight * 5) ? 
                                          Color.accentColor : Color.white.opacity(0.1))
                                    .frame(width: 8, height: 8)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            factor.weight = Double(index) / 5.0
                                        }
                                    }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(12)
                }
            }
            
            // New factor input
            HStack(spacing: 16) {
                TextField("Add a new factor", text: $newFactorName)
                    .modifier(PlaceholderModifier(
                        placeholder: "Add a new factor",
                        showPlaceholder: newFactorName.isEmpty
                    ))
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .foregroundColor(.white)
                
                if !newFactorName.isEmpty {
                    Button(action: addFactor) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
    }
    
    private func addFactor() {
        withAnimation(.spring(response: 0.3)) {
            factors.append(Factor(name: newFactorName, weight: 0.6, score: 0))
            newFactorName = ""
            isFocused = true
        }
    }
}