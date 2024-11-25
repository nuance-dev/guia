import SwiftUI

struct AddDecisionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @FocusState private var focusedField: Field?
    
    let onSave: (Decision) -> Void
    
    private enum Field {
        case title
        case description
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            Text("New Decision")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Decision title", text: $title)
                        .font(.system(size: 15))
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: .title)
                    
                    Divider()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Description (optional)", text: $description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .textFieldStyle(.plain)
                        .focused($focusedField, equals: .description)
                    
                    Divider()
                }
            }
            
            // Buttons
            HStack(spacing: 12) {
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
        .onAppear {
            focusedField = .title
        }
    }
} 