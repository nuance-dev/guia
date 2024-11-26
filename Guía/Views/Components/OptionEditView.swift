import SwiftUI

struct OptionEditView: View {
    enum Mode {
        case add
        case edit(OptionModel)
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var scores: [UUID: Double] = [:]
    
    let mode: Mode
    let onSave: (OptionModel) -> Void
    
    init(mode: Mode, onSave: @escaping (OptionModel) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        // Initialize state if editing
        if case .edit(let option) = mode {
            _name = State(initialValue: option.name)
            _description = State(initialValue: option.description ?? "")
            _notes = State(initialValue: option.notes ?? "")
            _scores = State(initialValue: option.scores)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Name", text: $name)
                TextField("Description (optional)", text: $description)
                TextField("Notes (optional)", text: $notes)
            }
        }
        .navigationTitle(mode == .add ? "Add Option" : "Edit Option")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(mode == .add ? "Add" : "Save") {
                    let option = OptionModel(
                        name: name,
                        description: description.isEmpty ? nil : description,
                        scores: scores,
                        notes: notes.isEmpty ? nil : notes
                    )
                    onSave(option)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
    }
} 