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
    
    // MARK: - Initialize
    init(decision: Decision, 
         analysisEngine: AnalysisEngine = AnalysisEngine(),
         storageService: StorageService = StorageService()) {
        self.decision = decision
        self.analysisEngine = analysisEngine
        self.storageService = storageService
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
    
    // MARK: - Analysis State
    enum AnalysisState {
        case idle
        case analyzing
        case completed(AnalysisResults)
        case error(Error)
    }
}

// MARK: - Decision Error
enum DecisionError: LocalizedError {
    case optionNotFound
    case criterionNotFound
    
    var errorDescription: String? {
        switch self {
        case .optionNotFound:
            return "The specified option was not found"
        case .criterionNotFound:
            return "The specified criterion was not found"
        }
    }
}