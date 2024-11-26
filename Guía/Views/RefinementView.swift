import SwiftUI

struct RefinementView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @State private var selectedOption: OptionModel?
    @State private var showingOptionEdit = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Sensitivity Analysis
            if let results = viewModel.analysisResults {
                SensitivityAnalysis(results: results)
            }
            
            // Options Refinement
            VStack(alignment: .leading, spacing: 16) {
                Text("Options")
                    .font(.headline)
                
                if viewModel.decision.options.isEmpty {
                    ContentUnavailableView(
                        "No Options to Refine",
                        systemImage: "slider.horizontal.3",
                        description: Text("Add options in the Options stage to refine them")
                    )
                } else {
                    ForEach(viewModel.decision.options) { option in
                        OptionRowView(option: option) {
                            selectedOption = option
                            showingOptionEdit = true
                        } onDelete: {
                            Task {
                                try await viewModel.deleteOption(option)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingOptionEdit) {
            if let option = selectedOption {
                OptionEditView(mode: .edit(option)) { updatedOption in
                    Task {
                        try await viewModel.updateOption(updatedOption)
                    }
                }
            }
        }
    }
}