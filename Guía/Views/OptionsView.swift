import SwiftUI

struct OptionsView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @State private var showingAddOption = false
    @State private var newOptionTitle = ""
    @State private var newOptionDescription = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Options")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddOption = true }) {
                    Label("Add Option", systemImage: "plus.circle.fill")
                }
            }
            .padding(.bottom, 8)
            
            if viewModel.decision.options.isEmpty {
                ContentEmptyStateView(
                    title: "No Options Added",
                    message: "Add at least two options to compare.",
                    systemImage: "list.bullet.circle"
                )
            } else {
                ForEach(viewModel.decision.options) { option in
                    OptionCard(option: option)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingAddOption) {
            AddOptionView(viewModel: viewModel)
        }
    }
}

struct OptionCard: View {
    let option: Option
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(option.name)
                .font(.headline)
            
            if let description = option.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !option.pros.isEmpty || !option.cons.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    if !option.pros.isEmpty {
                        ForEach(option.pros, id: \.self) { pro in
                            Label(pro, systemImage: "plus.circle")
                                .foregroundColor(.green)
                        }
                    }
                    
                    if !option.cons.isEmpty {
                        ForEach(option.cons, id: \.self) { con in
                            Label(con, systemImage: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }
                .font(.caption)
                .padding(.top, 4)
            }
            
            if let notes = option.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AddOptionView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var pros: [String] = [""]
    @State private var cons: [String] = [""]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Option Details")) {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description)
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
            }
            .navigationTitle("Add Option")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            let filteredPros = pros.filter { !$0.isEmpty }
                            let filteredCons = cons.filter { !$0.isEmpty }
                            
                            try await viewModel.addOption(
                                Option(
                                    name: name,
                                    description: description.isEmpty ? nil : description,
                                    pros: filteredPros,
                                    cons: filteredCons
                                )
                            )
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}