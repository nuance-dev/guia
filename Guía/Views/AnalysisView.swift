import SwiftUI

struct AnalysisView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @State private var selectedMethod: AnalysisMethod = .simple
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Analysis Method Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Analysis Method")
                    .font(.headline)
                
                Picker("Method", selection: $selectedMethod) {
                    Text("Simple Weighted Sum").tag(AnalysisMethod.simple)
                    Text("AHP").tag(AnalysisMethod.ahp)
                }
                .pickerStyle(.segmented)
            }
            
            // Analysis Results
            if case .completed(let results) = viewModel.analysisState {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Ranked Options
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Results")
                                .font(.headline)
                            
                            ForEach(results.rankedOptions) { option in
                                HStack {
                                    Text(viewModel.decision.options.first { $0.id == option.optionId }?.name ?? "")
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text(String(format: "%.2f", option.score))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Confidence Score
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confidence Score")
                                .font(.headline)
                            
                            Text(String(format: "%.0f%%", results.confidenceScore * 100))
                                .font(.title)
                                .fontWeight(.medium)
                        }
                        
                        // Sensitivity Analysis
                        if !results.sensitivityData.criticalCriteria.isEmpty {
                            SensitivityAnalysis(results: results)
                        }
                    }
                    .padding()
                }
            } else {
                // Analysis Button or Loading State
                VStack {
                    switch viewModel.analysisState {
                    case .idle:
                        Button("Run Analysis") {
                            Task {
                                try await viewModel.performAnalysis()
                            }
                        }
                        .buttonStyle(GlassButtonStyle())
                        
                    case .analyzing:
                        ProgressView()
                            .progressViewStyle(.circular)
                        Text("Analyzing...")
                            .foregroundColor(.secondary)
                        
                    case .error(let error):
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Analysis Error")
                                .font(.headline)
                            Text(error.localizedDescription)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
} 