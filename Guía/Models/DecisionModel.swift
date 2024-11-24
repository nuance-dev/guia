import Foundation

// MARK: - Decision Model
struct Decision: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var options: [Option]
    var criteria: [Criterion]
    var weights: [UUID: Double] // Criteria ID to weight mapping
    var created: Date
    var modified: Date
    
    // MARK: - Analysis Results
    var analysisResults: AnalysisResults?
    
    var state: DecisionState {
        if options.isEmpty || criteria.isEmpty {
            return .empty
        }
        if !validateWeights() || !validateAllScores() {
            return .incomplete
        }
        return analysisResults == nil ? .ready : .analyzed
    }
    
    private func validateAllScores() -> Bool {
        options.allSatisfy { option in
            option.validateScores(against: criteria)
        }
    }
    
    // MARK: - Initialize
    init(id: UUID = UUID(),
         title: String,
         description: String? = nil,
         options: [Option] = [],
         criteria: [Criterion] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.options = options
        self.criteria = criteria
        self.weights = [:]
        self.created = Date()
        self.modified = Date()
        
        // Initialize weights from criteria
        for criterion in criteria {
            self.weights[criterion.id] = criterion.effectiveWeight
        }
    }
    
    // MARK: - Helper Methods
    func validateWeights() -> Bool {
        guard !weights.isEmpty else { return false }
        
        // Check if all criteria have weights
        for criterion in criteria {
            if weights[criterion.id] == nil {
                return false
            }
        }
        
        // Check if weights sum is approximately 1.0 (allowing for floating-point imprecision)
        let sum = weights.values.reduce(0, +)
        return abs(sum - 1.0) < 0.0001
    }
    
    func normalizeWeights() -> [UUID: Double] {
        let sum = weights.values.reduce(0, +)
        guard sum > 0 else { return [:] }
        
        var normalized = [UUID: Double]()
        for (id, weight) in weights {
            normalized[id] = weight / sum
        }
        return normalized
    }
    
    // MARK: - Analysis Methods
    private var lastAnalysisMethod: AnalysisMethod?
    
    mutating func calculateResults(using method: AnalysisMethod) async throws {
        // Skip if already calculated with same method
        if let lastMethod = lastAnalysisMethod,
           lastMethod == method,
           analysisResults != nil {
            return
        }
        
        guard validateWeights() else {
            throw AnalysisError.insufficientData
        }
        
        // Validate that all options have scores for all criteria
        for option in options {
            if !option.validateScores(against: criteria) {
                throw AnalysisError.insufficientData
            }
        }
        
        let engine = AnalysisEngine()
        analysisResults = try await engine.analyze(decision: self, method: method)
        lastAnalysisMethod = method
        modified = Date()
    }
    
    mutating func updateWeight(for criterionId: UUID, to value: Double) {
        weights[criterionId] = value
        modified = Date()
        // Reset analysis when weights change
        analysisResults = nil
    }
    
    mutating func distributeWeightsEvenly() {
        guard !criteria.isEmpty else { return }
        let evenWeight = 1.0 / Double(criteria.count)
        criteria.forEach { criterion in
            weights[criterion.id] = evenWeight
        }
        modified = Date()
        analysisResults = nil
    }
    
    struct Snapshot: Codable {
        let weights: [UUID: Double]
        let options: [Option]
        let timestamp: Date
    }
    
    func createSnapshot() -> Snapshot {
        Snapshot(
            weights: weights,
            options: options,
            timestamp: Date()
        )
    }
    
    mutating func restore(from snapshot: Snapshot) {
        weights = snapshot.weights
        options = snapshot.options
        modified = Date()
        analysisResults = nil
        lastAnalysisMethod = nil
    }
    
    struct Progress {
        let criteriaComplete: Bool
        let optionsComplete: Bool
        let weightsComplete: Bool
        let percentage: Double
        
        var isComplete: Bool {
            criteriaComplete && optionsComplete && weightsComplete
        }
    }
    
    var progress: Progress {
        let hasValidCriteria = !criteria.isEmpty
        let hasValidOptions = !options.isEmpty
        let hasValidWeights = validateWeights()
        
        let total = 3.0
        var completed = 0.0
        if hasValidCriteria { completed += 1 }
        if hasValidOptions { completed += 1 }
        if hasValidWeights { completed += 1 }
        
        return Progress(
            criteriaComplete: hasValidCriteria,
            optionsComplete: hasValidOptions,
            weightsComplete: hasValidWeights,
            percentage: completed / total
        )
    }
}
