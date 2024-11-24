import SwiftUI

struct OptionListView: View {
    // MARK: - Properties
    @Binding var options: [Option]
    @State private var draggedOption: Option?
    @State private var showingAddSheet = false
    @State private var editingOption: Option?
    
    // MARK: - Body
    var body: some View {
        List {
            ForEach(options) { option in
                OptionRowView(
                    option: option,
                    onEdit: { editingOption = option },
                    onDelete: { deleteOption(option) }
                )
                .contextMenu {
                    Button("Edit") { editingOption = option }
                    Button("Duplicate") { duplicateOption(option) }
                    Divider()
                    Button("Delete", role: .destructive) { deleteOption(option) }
                }
            }
            .onMove { source, destination in
                options.move(fromOffsets: source, toOffset: destination)
            }
        }
        .listStyle(.inset)
        .toolbar {
            ToolbarItem {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Option", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            OptionEditView(mode: .add) { newOption in
                options.append(newOption)
                showingAddSheet = false
            }
        }
        .sheet(item: $editingOption) { option in
            OptionEditView(mode: .edit(option)) { updatedOption in
                if let index = options.firstIndex(where: { $0.id == option.id }) {
                    options[index] = updatedOption
                }
                editingOption = nil
            }
        }
    }
    
    // MARK: - Private Methods
    private func duplicateOption(_ option: Option) {
        let duplicate = Option(
            id: UUID(),
            name: option.name + " (Copy)",
            description: option.description,
            scores: option.scores,
            notes: option.notes
        )
        options.append(duplicate)
    }
    
    private func deleteOption(_ option: Option) {
        if let index = options.firstIndex(where: { $0.id == option.id }) {
            options.remove(at: index)
        }
    }
}

// MARK: - Supporting Views
struct OptionRowView: View {
    let option: Option
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(option.name)
                    .font(.headline)
                
                if let description = option.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Score indicators
            HStack(spacing: 8) {
                ForEach(option.scores.sorted(by: { $0.key < $1.key }), id: \.key) { _, score in
                    ScoreIndicator(score: score)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ScoreIndicator: View {
    let score: Double
    
    var body: some View {
        Circle()
            .fill(scoreColor)
            .frame(width: 8, height: 8)
    }
    
    private var scoreColor: Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .yellow
        case 0.2..<0.4: return .orange
        default: return .red
        }
    }
}