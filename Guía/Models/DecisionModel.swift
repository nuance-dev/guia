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
    mutating func calculateResults(using method: AnalysisMethod) async throws {
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
        modified = Date()
    }
}
