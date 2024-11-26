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
            Section {
                TextField("Name", text: $name)
                TextField("Description (optional)", text: $description)
                TextField("Unit (optional)", text: $unit)
            }
            
            Section {
                Picker("Importance", selection: $importance) {
                    ForEach(BasicCriterion.Importance.allCases, id: \.self) { importance in
                        Text(importance.title).tag(importance)
                    }
                }
                .pickerStyle(.segmented)
            }
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

private extension BasicCriterion.Importance {
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
} 