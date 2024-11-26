import SwiftUI

struct DecisionDetailView: View {
    let decision: Decision
    @StateObject private var viewModel: DecisionViewModel
    @State private var selectedStage: DecisionStage = .problem
    
    init(decision: Decision) {
        self.decision = decision
        self._viewModel = StateObject(wrappedValue: DecisionViewModel(decision: decision))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding()
                .background(.background)
            
            Divider()
            
            // Stage Navigation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(DecisionStage.allCases, id: \.self) { stage in
                        StageButton(
                            stage: stage,
                            isSelected: stage == selectedStage,
                            isCompleted: viewModel.isStageCompleted(stage),
                            action: { selectedStage = stage }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(.background)
            
            Divider()
            
            // Content
            ScrollView {
                stageContent
                    .padding()
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(decision.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let description = decision.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let primaryInsight = viewModel.primaryInsight {
                InsightBadge(insight: primaryInsight)
                    .padding(.top, 4)
            }
        }
    }
    
    @ViewBuilder
    private var stageContent: some View {
        switch selectedStage {
        case .problem:
            ProblemDefinitionView(viewModel: viewModel)
        case .stakeholders:
            StakeholderView(decision: decision)
        case .options:
            OptionsView(viewModel: viewModel)
        case .criteria:
            CriteriaView(viewModel: viewModel)
        case .weights:
            WeightsView(viewModel: viewModel)
        case .analysis:
            AnalysisView(viewModel: viewModel)
        case .refinement:
            RefinementView(viewModel: viewModel)
        case .validation:
            ValidationView(viewModel: viewModel)
        }
    }
}

struct StageButton: View {
    let stage: DecisionStage
    let isSelected: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: stage.systemImage)
                    .font(.system(size: 16))
                Text(stage.title)
                    .font(.caption)
            }
            .frame(width: 80)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.1) : .clear)
            .foregroundColor(isSelected ? .accentColor : .primary)
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(.accent)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
                    .padding(4)
            }
        }
    }
}

struct StakeholderView: View {
    let decision: Decision
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Stakeholder Analysis")
                .font(.headline)
                .padding(.bottom, 8)
            
            if let stakeholders = decision.cognitiveContext?.stakeholderImpact, !stakeholders.isEmpty {
                ForEach(stakeholders, id: \.stakeholder) { stakeholder in
                    StakeholderCard(stakeholder: stakeholder)
                }
            } else {
                ContentEmptyStateView(
                    title: "No Stakeholders Added",
                    message: "Add stakeholders to analyze their impact on your decision.",
                    systemImage: "person.2.slash"
                )
            }
        }
        .padding()
    }
}

struct StakeholderCard: View {
    let stakeholder: CognitiveFramework.StakeholderImpact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(stakeholder.stakeholder)
                .font(.headline)
            
            HStack {
                Label("Impact", systemImage: "arrow.up.arrow.down")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f", stakeholder.impact))
            }
            
            HStack {
                Label("Influence", systemImage: "chart.bar")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f", stakeholder.influence))
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ContentEmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

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
    let option: Decision.Option
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(option.title)
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
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AddOptionView: View {
    @ObservedObject var viewModel: DecisionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var pros: [String] = [""]
    @State private var cons: [String] = [""]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Option Details")) {
                    TextField("Title", text: $title)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let filteredPros = pros.filter { !$0.isEmpty }
                        let filteredCons = cons.filter { !$0.isEmpty }
                        Task {
                            try await viewModel.addOption(
                                Option(
                                    title: title,
                                    description: description.isEmpty ? nil : description,
                                    pros: filteredPros,
                                    cons: filteredCons
                                )
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

#Preview {
    DecisionDetailView(
        decision: Decision(
            id: UUID(),
            title: "Sample Decision",
            description: "A sample decision for preview",
            context: Decision.DecisionContext(
                timeframe: .immediate,
                impact: .medium,
                reversibility: true
            ),
            options: [OptionModel(name: "Sample Option")],
            criteria: [],
            weights: [:],
            evaluation: Decision.Evaluation(criteria: [], scores: [:]),
            insights: [],
            state: .empty,
            created: Date(),
            modified: Date()
        )
    )
} 