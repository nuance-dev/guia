import SwiftUI

struct ProblemDefinitionView: View {
    let decision: Decision
    @StateObject private var viewModel: DecisionViewModel
    @State private var editedTitle: String
    @State private var editedDescription: String
    
    init(decision: Decision) {
        self.decision = decision
        self._viewModel = StateObject(wrappedValue: DecisionViewModel(decision: decision))
        self._editedTitle = State(initialValue: decision.title)
        self._editedDescription = State(initialValue: decision.description ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Define the Problem")
                .font(.title3)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("What decision are you making?", text: $editedTitle)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $editedDescription)
                        .font(.body)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            HStack {
                Spacer()
                Button("Save Changes") {
                    Task {
                        try await viewModel.updateProblem(
                            title: editedTitle,
                            description: editedDescription.isEmpty ? nil : editedDescription
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(editedTitle.isEmpty || editedTitle == decision.title && editedDescription == (decision.description ?? ""))
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProblemDefinitionView(decision: Decision(title: "Sample Decision"))
        .padding()
} 