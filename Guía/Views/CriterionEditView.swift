import SwiftUI

struct CriterionEditView: View {
    @State private var name = ""
    @State private var description = ""
    @State private var unit = ""
    @State private var importance = BasicCriterion.Importance.medium
    @Environment(\.dismiss) var dismiss
    
    let onSave: (BasicCriterion) -> Void
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Description (optional)", text: $description)
            TextField("Unit (optional)", text: $unit)
            Picker("Importance", selection: $importance) {
                Text("Low").tag(BasicCriterion.Importance.low)
                Text("Medium").tag(BasicCriterion.Importance.medium)
                Text("High").tag(BasicCriterion.Importance.high)
            }
            .pickerStyle(.segmented)
        }
        .navigationTitle("New Criterion")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard !name.isEmpty else { return }
                    
                    let criterion = BasicCriterion(
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
    }
} 