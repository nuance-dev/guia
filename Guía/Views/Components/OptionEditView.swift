import SwiftUI

struct OptionEditView: View {
    enum Mode {
        case add
        case edit(Option)
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var notes = ""
    
    let mode: Mode
    let onSave: (Option) -> Void
    
    init(mode: Mode, onSave: @escaping (Option) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        // Initialize state if editing
        if case .edit(let option) = mode {
            _name = State(initialValue: option.name)
            _description = State(initialValue: option.description ?? "")
            _notes = State(initialValue: option.notes ?? "")
        }
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Description", text: $description)
            TextField("Notes", text: $notes)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    let option = Option(
                        name: name,
                        description: description.isEmpty ? nil : description,
                        notes: notes.isEmpty ? nil : notes
                    )
                    onSave(option)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
} 