import SwiftUI

struct ValidationView: View {
    @ObservedObject var viewModel: DecisionViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Validation Status
            VStack(alignment: .leading, spacing: 16) {
                Text("Validation Status")
                    .font(.headline)
                
                if let results = viewModel.validationResults {
                    ForEach(results.validationChecks, id: \.id) { check in
                        ValidationCheckRow(check: check)
                    }
                } else {
                    ContentUnavailableView(
                        "No Validation Results",
                        systemImage: "checkmark.shield",
                        description: Text("Complete previous stages to validate your decision")
                    )
                }
            }
            
            // Recommendations
            if !viewModel.validationRecommendations.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommendations")
                        .font(.headline)
                    
                    ForEach(viewModel.validationRecommendations, id: \.self) { recommendation in
                        RecommendationCard(recommendation: recommendation)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct ValidationCheckRow: View {
    let check: ValidationCheck
    
    var body: some View {
        HStack {
            Image(systemName: check.isPassing ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(check.isPassing ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(check.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(check.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct RecommendationCard: View {
    let recommendation: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            
            Text(recommendation)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
} 