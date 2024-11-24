import SwiftUI

struct CriterionEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var importance = Criterion.Importance.medium
    @State private var unit = ""
    
    let onSave: (Criterion) -> Void
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Description", text: $description)
            TextField("Unit (optional)", text: $unit)
            
            Picker("Importance", selection: $importance) {
                Text("Low").tag(Criterion.Importance.low)
                Text("Medium").tag(Criterion.Importance.medium)
                Text("High").tag(Criterion.Importance.high)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    let criterion = Criterion(
                        name: name,
                        description: description.isEmpty ? nil : description,
                        importance: importance,
                        unit: unit.isEmpty ? nil : unit
                    )
                    onSave(criterion)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
} 