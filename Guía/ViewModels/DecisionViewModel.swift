import SwiftUI
import Combine

@MainActor
final class DecisionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var decision: Decision
    @Published private(set) var analysisState: AnalysisState = .idle
    @Published var selectedMethod: AnalysisMethod = .simple
    
    // MARK: - Dependencies
    private let analysisEngine: AnalysisEngine
    private let storageService: StorageService
    private let flowCoordinator: DecisionFlowCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialize
    init(decision: Decision,
         analysisEngine: AnalysisEngine = AnalysisEngine(),
         storageService: StorageService = StorageService()) {
        self.decision = decision
        self.analysisEngine = analysisEngine
        self.storageService = storageService
        self.flowCoordinator = DecisionFlowCoordinator(
            decision: decision,
            analysisEngine: analysisEngine
        )
        
        setupBindings()
    }
    
    private func setupBindings() {
        flowCoordinator.$currentStage
            .sink { [weak self] stage in
                self?.handleStageChange(stage)
            }
            .store(in: &cancellables)
            
        flowCoordinator.$insights
            .sink { [weak self] insights in
                self?.handleNewInsights(insights)
            }
            .store(in: &cancellables)
    }
    
    func moveToNextStage() async throws {
        try await flowCoordinator.moveToNextStage()
    }
    
    private func handleStageChange(_ stage: DecisionStage) {
        // Update UI and state based on stage changes
        switch stage {
        case .analysis:
            Task { try await performAnalysis() }
        case .validation:
            validateDecision()
        default:
            break
        }
    }
    
    // MARK: - Public Methods
    func addOption(_ option: Option) async throws {
        decision.options.append(option)
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func updateOption(_ option: Option) async throws {
        guard let index = decision.options.firstIndex(where: { $0.id == option.id }) else {
            throw DecisionError.optionNotFound
        }
        
        decision.options[index] = option
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func deleteOption(_ option: Option) async throws {
        decision.options.removeAll { $0.id == option.id }
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func addCriterion(_ criterion: Criterion) async throws {
        decision.criteria.append(criterion)
        decision.weights[criterion.id] = criterion.effectiveWeight
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func updateCriterion(_ criterion: Criterion) async throws {
        guard let index = decision.criteria.firstIndex(where: { $0.id == criterion.id }) else {
            throw DecisionError.criterionNotFound
        }
        
        decision.criteria[index] = criterion
        decision.weights[criterion.id] = criterion.effectiveWeight
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func deleteCriterion(_ criterion: Criterion) async throws {
        decision.criteria.removeAll { $0.id == criterion.id }
        decision.weights.removeValue(forKey: criterion.id)
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func updateWeight(for criterion: Criterion, to value: Double) async throws {
        guard decision.criteria.contains(where: { $0.id == criterion.id }) else {
            throw DecisionError.criterionNotFound
        }
        
        let normalizedValue = max(0, min(1, value))
        decision.weights[criterion.id] = normalizedValue
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func performAnalysis() async throws {
        analysisState = .analyzing
        
        do {
            let results = try await analysisEngine.analyze(
                decision: decision,
                method: selectedMethod
            )
            decision.analysisResults = results
            analysisState = .completed(results)
            
            // Update decision with analysis results
            decision.modified = Date()
            try await storageService.updateDecision(decision)
        } catch {
            analysisState = .error(error)
        }
    }
    
    func updatePairwiseComparisons(_ comparisons: [[Double]]) async throws {
        decision.pairwiseComparisons = comparisons
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    // MARK: - Analysis State
    enum AnalysisState {
        case idle
        case analyzing
        case completed(AnalysisResults)
        case error(Error)
    }
    
    private func handleNewInsights(_ insights: [DecisionFlowCoordinator.DecisionInsight]) {
        // Update the decision with new insights
        decision.modified = Date()
        
        // Store insights for UI updates
        Task {
            try await storageService.updateDecision(decision)
        }
    }
    
    private func validateDecision() {
        // Validate decision completeness and quality
        let hasMinimumOptions = decision.options.count >= 2
        let hasMinimumCriteria = decision.criteria.count >= 1
        let hasCompleteScores = decision.options.allSatisfy { option in
            decision.criteria.allSatisfy { criterion in
                option.scores[criterion.id] != nil
            }
        }
        
        if !hasMinimumOptions || !hasMinimumCriteria || !hasCompleteScores {
            analysisState = .error(DecisionError.validationFailed)
        }
    }
    
    var completionProgress: Double {
        let totalSteps = Double(DecisionStage.allCases.count)
        let completedSteps = Double(DecisionStage.allCases.firstIndex(of: flowCoordinator.currentStage) ?? 0)
        return completedSteps / totalSteps
    }
    
    var nextActionTitle: String {
        flowCoordinator.currentStage.title
    }
    
    var nextActionDescription: String {
        "Complete this step to move forward"
    }
    
    var nextActionIcon: String {
        flowCoordinator.currentStage.systemImage
    }
    
    var primaryInsight: Decision.Insight? {
        decision.insights.first
    }
    
    func performNextAction() {
        Task {
            try await moveToNextStage()
        }
    }
}

// MARK: - Decision Error
enum DecisionError: LocalizedError {
    case stageIncomplete(blockers: [String])
    case optionNotFound
    case criterionNotFound
    case validationFailed
    
    var errorDescription: String? {
        switch self {
        case .stageIncomplete(let blockers):
            return "Stage is incomplete: \(blockers.joined(separator: ", "))"
        case .optionNotFound:
            return "The specified option was not found"
        case .criterionNotFound:
            return "The specified criterion was not found"
        case .validationFailed:
            return "Decision validation failed"
        }
    }
}