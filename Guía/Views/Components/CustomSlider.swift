import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    @GestureState private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Gradient track
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.red.opacity(0.8),
                        Color.yellow.opacity(0.8),
                        Color.green.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: max(0, min(geometry.size.width * CGFloat(value), geometry.size.width)), height: 4)
                .cornerRadius(2)
                
                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .position(x: max(8, min(geometry.size.width * CGFloat(value), geometry.size.width - 8)), 
                            y: geometry.size.height / 2)
            }
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        let newValue = min(max(gesture.location.x / geometry.size.width, 0), 1)
                        value = Double(newValue)
                    }
            )
        }
        .frame(height: 24)
    }
} 