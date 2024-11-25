import SwiftUI

struct NewDecisionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    
    let onSave: (Decision) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("New Decision")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title", text: $title)
                    .textFieldStyle(.plain)
                    .font(.headline)
                
                TextField("Description (optional)", text: $description)
                    .textFieldStyle(.plain)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                
                Button("Create") {
                    let decision = Decision(
                        title: title,
                        description: description.isEmpty ? nil : description
                    )
                    onSave(decision)
                    dismiss()
                }
                .buttonStyle(GlassButtonStyle())
                .disabled(title.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400)
    }
} 