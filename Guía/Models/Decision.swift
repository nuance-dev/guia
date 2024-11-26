import Foundation

struct Decision: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var options: [Option]
    var criteria: [Criterion]
    var created: Date
    var modified: Date
    
    struct Option: Identifiable, Codable {
        let id: UUID
        var name: String
        var description: String?
        var scores: [UUID: Double]
        
        init(id: UUID = UUID(), name: String, description: String? = nil) {
            self.id = id
            self.name = name
            self.description = description
            self.scores = [:]
        }
    }
    
    struct Criterion: Identifiable, Codable {
        let id: UUID
        var name: String
        var description: String?
        var weight: Double
        
        init(id: UUID = UUID(), name: String, description: String? = nil, weight: Double = 1.0) {
            self.id = id
            self.name = name
            self.description = description
            self.weight = weight
        }
    }
    
    struct Analysis: Codable {
        var recommendedOption: UUID
        var confidence: Double
        var reasoning: String
        var scores: [UUID: Double]
        
        init(recommendedOption: UUID, confidence: Double, reasoning: String, scores: [UUID: Double]) {
            self.recommendedOption = recommendedOption
            self.confidence = confidence
            self.reasoning = reasoning
            self.scores = scores
        }
    }
    
    var analysis: Analysis? {
        guard !options.isEmpty && !criteria.isEmpty else { return nil }
        
        // Calculate weighted scores
        var optionScores: [UUID: Double] = [:]
        for option in options {
            var totalScore = 0.0
            var totalWeight = 0.0
            
            for criterion in criteria {
                let score = option.scores[criterion.id] ?? 0
                totalScore += score * criterion.weight
                totalWeight += criterion.weight
            }
            
            optionScores[option.id] = totalWeight > 0 ? totalScore / totalWeight : 0
        }
        
        // Find best option
        guard let bestOption = optionScores.max(by: { $0.value < $1.value }) else { return nil }
        
        // Calculate confidence based on score spread
        let scoreSpread = optionScores.values.max()! - optionScores.values.min()!
        let confidence = min(1.0, scoreSpread * 2) // Higher spread = higher confidence
        
        // Generate reasoning
        let reasoning = generateReasoning(bestOptionId: bestOption.key, scores: optionScores)
        
        return Analysis(
            recommendedOption: bestOption.key,
            confidence: confidence,
            reasoning: reasoning,
            scores: optionScores
        )
    }
    
    private func generateReasoning(bestOptionId: UUID, scores: [UUID: Double]) -> String {
        guard let bestOption = options.first(where: { $0.id == bestOptionId }) else { return "" }
        
        let strengths = criteria.filter { criterion in
            bestOption.scores[criterion.id] ?? 0 >= 0.7
        }.map { $0.name }
        
        return """
        \(bestOption.name) is recommended because it performs well in \
        \(strengths.joined(separator: ", ")).
        """
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        options: [Option] = [],
        criteria: [Criterion] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.options = options
        self.criteria = criteria
        self.created = Date()
        self.modified = Date()
    }
}
