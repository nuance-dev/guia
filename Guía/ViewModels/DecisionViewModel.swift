import SwiftUI
import Combine

@MainActor
final class DecisionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var decision: Decision
    @Published private(set) var analysisState: AnalysisState = .idle
    @Published private(set) var validationResults: ValidationResults?
    @Published var selectedMethod: AnalysisMethod = .simple
    
    var validationRecommendations: [String] {
        guard let results = validationResults else { return [] }
        return results.validationChecks.filter { !$0.isPassing }.map { check in
            "\(check.title): \(check.description)"
        }
    }
    
    var analysisResults: AnalysisResults? {
        decision.analysisResults
    }
    
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
    func addOption(_ option: OptionModel) async throws {
        decision.options.append(option)
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func updateOptions(_ options: [OptionModel]) async throws {
        decision.options = options
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func updateOption(_ option: OptionModel) async throws {
        guard let index = decision.options.firstIndex(where: { $0.id == option.id }) else {
            throw DecisionError.optionNotFound
        }
        
        decision.options[index] = option
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func deleteOption(_ option: OptionModel) async throws {
        decision.options.removeAll { $0.id == option.id }
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func addCriterion(_ criterion: any Criterion) async throws {
        if let basicCriterion = criterion as? BasicCriterion {
            decision.criteria.append(basicCriterion)
            decision.weights[criterion.id] = criterion.weight
            decision.modified = Date()
            try await storageService.updateDecision(decision)
        } else {
            throw DecisionError.invalidCriterionType
        }
    }
    
    func updateCriterion(_ criterion: any Criterion) async throws {
        guard let basicCriterion = criterion as? BasicCriterion,
              let index = decision.criteria.firstIndex(where: { $0.id == criterion.id }) else {
            throw DecisionError.criterionNotFound
        }
        
        decision.criteria[index] = basicCriterion
        decision.weights[criterion.id] = criterion.weight
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func deleteCriterion(_ criterion: any Criterion) async throws {
        guard let basicCriterion = criterion as? BasicCriterion else {
            throw DecisionError.invalidCriterionType
        }
        decision.criteria.removeAll { $0.id == basicCriterion.id }
        decision.weights.removeValue(forKey: basicCriterion.id)
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
    
    func updateWeight(for criterion: any Criterion, to value: Double) async throws {
        guard let index = decision.criteria.firstIndex(where: { $0.id == criterion.id }) else {
            throw DecisionError.criterionNotFound
        }
        
        decision.weights[criterion.id] = value
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
        // Create validation checks
        var checks = [ValidationCheck]()
        
        // Check minimum options
        checks.append(ValidationCheck(
            title: "Minimum Options",
            description: "Decision should have at least 2 options",
            isPassing: decision.options.count >= 2
        ))
        
        // Check minimum criteria
        checks.append(ValidationCheck(
            title: "Minimum Criteria",
            description: "Decision should have at least 1 criterion",
            isPassing: decision.criteria.count >= 1
        ))
        
        // Check complete scores
        let hasCompleteScores = decision.options.allSatisfy { option in
            decision.criteria.allSatisfy { criterion in
                option.scores[criterion.id] != nil
            }
        }
        checks.append(ValidationCheck(
            title: "Complete Scores",
            description: "All options should have scores for all criteria",
            isPassing: hasCompleteScores
        ))
        
        // Update validation results
        validationResults = ValidationResults(
            validationChecks: checks,
            isValid: checks.allSatisfy(\.isPassing)
        )
        
        if !checks.allSatisfy(\.isPassing) {
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
    
    func isStageCompleted(_ stage: DecisionStage) -> Bool {
        switch stage {
        case .problem:
            return !decision.title.isEmpty
        case .stakeholders:
            return decision.cognitiveContext?.stakeholderImpact.count ?? 0 > 0
        case .options:
            return decision.options.count >= 2
        case .criteria:
            return !decision.criteria.isEmpty
        case .weights:
            return decision.validateWeights()
        case .analysis:
            return decision.analysisResults != nil
        case .refinement:
            return true // Always allow refinement
        case .validation:
            return decision.evaluation.isComplete
        }
    }
    
    func updateProblem(title: String, description: String?) async throws {
        decision.title = title
        decision.description = description
        decision.modified = Date()
        try await storageService.updateDecision(decision)
    }
}

// MARK: - Decision Error
enum DecisionError: LocalizedError {
    case stageIncomplete(blockers: [String])
    case optionNotFound
    case criterionNotFound
    case validationFailed
    case invalidCriterionType
    
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
        case .invalidCriterionType:
            return "Invalid criterion type"
        }
    }
}