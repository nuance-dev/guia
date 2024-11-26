import SwiftUI

struct HeaderView: View {
    let progress: Double
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Guía")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                if flowManager.currentStep != .initial {
                    Button(action: { flowManager.showResetAlert() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .alert("Start Over?", isPresented: $flowManager.showResetConfirmation) {
                        Button("Cancel", role: .cancel) { }
                        Button("Reset", role: .destructive) {
                            flowManager.resetFlow()
                        }
                    } message: {
                        Text("This will clear all your current progress.")
                    }
                }
                
                ConfidenceIndicator(value: progress)
                    .frame(width: 100, height: 4)
            }
            .frame(height: 44)
        }
    }
} 