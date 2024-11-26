import SwiftUI

enum OptionEditMode {
    case add
    case edit(OptionModel)
}

struct OptionEditView: View {
    let mode: OptionEditMode
    let onSave: (OptionModel) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var notes: String = ""
    
    init(mode: OptionEditMode, onSave: @escaping (OptionModel) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .add:
            break
        case .edit(let option):
            _name = State(initialValue: option.name)
            _description = State(initialValue: option.description ?? "")
            _notes = State(initialValue: option.notes ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Notes", text: $notes)
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
                    Button("Save") {
                        let option: OptionModel
                        switch mode {
                        case .add:
                            option = OptionModel(
                                name: name,
                                description: description.isEmpty ? nil : description,
                                notes: notes.isEmpty ? nil : notes
                            )
                        case .edit(let existingOption):
                            option = OptionModel(
                                id: existingOption.id,
                                name: name,
                                description: description.isEmpty ? nil : description,
                                scores: existingOption.scores,
                                notes: notes.isEmpty ? nil : notes
                            )
                        }
                        onSave(option)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    OptionEditView(mode: .add) { _ in }
} 