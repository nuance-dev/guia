import SwiftUI

struct EmptyStateView: View {
    let onAddDecision: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 36, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 12) {
                Text("Make Better Decisions")
                    .font(.system(size: 24, weight: .medium))
                
                Text("Break down complex choices into clear, actionable steps")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            
            Button(action: onAddDecision) {
                Text("Start Your First Decision")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
} 