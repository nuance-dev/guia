import SwiftUI

struct OptionListView: View {
    // MARK: - Properties
    @Binding var options: [Option]
    @State private var draggedOption: Option?
    @State private var showingAddSheet = false
    
    // MARK: - Body
    var body: some View {
        List {
            ForEach(options) { option in
                OptionRowView(option: option)
                    .contextMenu {
                        Button("Edit") { /* TODO */ }
                        Button("Duplicate") { /* TODO */ }
                        Divider()
                        Button("Delete", role: .destructive) { /* TODO */ }
                    }
            }
            .onDrop(of: [.text], delegate: OptionDropDelegate(options: $options))
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
            OptionEditView(mode: .add)
        }
    }
    
    // MARK: - Private Methods
    private func moveOption(from source: IndexSet, to destination: Int)
    private func deleteOption(_ option: Option)
}

// MARK: - Option Row View
private struct OptionRowView: View {
    let option: Option
    
    var body: some View {
        // TODO: Implement option row with score indicators
    }
}