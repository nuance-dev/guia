import SwiftUI

struct OptionsView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @State private var showingAddOption = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Options")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddOption = true }) {
                    Label("Add Option", systemImage: "plus.circle.fill")
                }
            }
            .padding(.bottom, 8)
            
            if viewModel.decision.options.isEmpty {
                ContentUnavailableView(
                    "No Options Added",
                    systemImage: "list.bullet",
                    description: Text("Add at least two options to compare")
                )
            } else {
                OptionListView(options: Binding(
                    get: { viewModel.decision.options },
                    set: { newValue in
                        Task {
                            try await viewModel.updateOptions(newValue)
                        }
                    }
                ))
            }
        }
        .padding()
        .sheet(isPresented: $showingAddOption) {
            NavigationStack {
                OptionEditView(mode: .add) { option in
                    Task {
                        try await viewModel.addOption(option)
                    }
                }
            }
        }
    }
}