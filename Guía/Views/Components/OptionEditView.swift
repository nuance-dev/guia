import SwiftUI

struct OptionEditView: View {
    enum Mode {
        case add
        case edit(Decision.Option)
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var notes = ""
    @State private var pros: [String] = [""]
    @State private var cons: [String] = [""]
    
    let mode: Mode
    let onSave: (Decision.Option) -> Void
    
    init(mode: Mode, onSave: @escaping (Decision.Option) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        // Initialize state if editing
        if case .edit(let option) = mode {
            _title = State(initialValue: option.title)
            _description = State(initialValue: option.description ?? "")
            _notes = State(initialValue: option.notes ?? "")
            _pros = State(initialValue: option.pros.isEmpty ? [""] : option.pros)
            _cons = State(initialValue: option.cons.isEmpty ? [""] : option.cons)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Notes", text: $notes)
            }
            
            Section(header: Text("Pros")) {
                ForEach($pros.indices, id: \.self) { index in
                    HStack {
                        TextField("Pro", text: $pros[index])
                        if index == pros.count - 1 {
                            Button(action: { pros.append("") }) {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }
            }
            
            Section(header: Text("Cons")) {
                ForEach($cons.indices, id: \.self) { index in
                    HStack {
                        TextField("Con", text: $cons[index])
                        if index == cons.count - 1 {
                            Button(action: { cons.append("") }) {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    let filteredPros = pros.filter { !$0.isEmpty }
                    let filteredCons = cons.filter { !$0.isEmpty }
                    
                    let option = Decision.Option(
                        title: title,
                        description: description.isEmpty ? nil : description,
                        pros: filteredPros,
                        cons: filteredCons,
                        notes: notes.isEmpty ? nil : notes
                    )
                    onSave(option)
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
} 