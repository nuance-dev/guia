import SwiftUI

struct EmptyAnalysisView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Analysis Results")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add options and criteria, then run analysis to see results")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}