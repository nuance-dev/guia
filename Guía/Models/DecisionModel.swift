import Foundation
import CoreData

// MARK: - Decision Model
struct Decision: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var context: DecisionContext
    var options: [Option]
    var criteria: [Criterion]
    var weights: [UUID: Double]
    var evaluation: Evaluation
    var insights: [Insight]
    var pairwiseComparisons: [[Double]]?
    var analysisResults: AnalysisResults?
    var state: DecisionState
    var created: Date
    var modified: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        context = try container.decode(DecisionContext.self, forKey: .context)
        options = try container.decode([Option].self, forKey: .options)
        criteria = try container.decode([Criterion].self, forKey: .criteria)
        weights = try container.decode([UUID: Double].self, forKey: .weights)
        evaluation = try container.decode(Evaluation.self, forKey: .evaluation)
        insights = try container.decode([Insight].self, forKey: .insights)
        pairwiseComparisons = try container.decodeIfPresent([[Double]].self, forKey: .pairwiseComparisons)
        analysisResults = try container.decodeIfPresent(AnalysisResults.self, forKey: .analysisResults)
        state = try container.decode(DecisionState.self, forKey: .state)
        created = try container.decode(Date.self, forKey: .created)
        modified = try container.decode(Date.self, forKey: .modified)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(context, forKey: .context)
        try container.encode(options, forKey: .options)
        try container.encode(criteria, forKey: .criteria)
        try container.encode(weights, forKey: .weights)
        try container.encode(evaluation, forKey: .evaluation)
        try container.encode(insights, forKey: .insights)
        try container.encodeIfPresent(pairwiseComparisons, forKey: .pairwiseComparisons)
        try container.encodeIfPresent(analysisResults, forKey: .analysisResults)
        try container.encode(state, forKey: .state)
        try container.encode(created, forKey: .created)
        try container.encode(modified, forKey: .modified)
    }
    
    struct DecisionContext: Codable {
        var timeframe: Timeframe
        var impact: Impact
        var reversibility: Bool
        
        enum Timeframe: String, Codable {
            case immediate
            case shortTerm
            case longTerm
            
            var suggestedApproach: String {
                switch self {
                case .immediate: return "Focus on gut feeling and quick pros/cons"
                case .shortTerm: return "Balance data with intuition"
                case .longTerm: return "Prioritize thorough analysis and future implications"
                }
            }
        }
        
        enum Impact: String, Codable {
            case low, medium, high
            
            var recommendedDepth: String {
                switch self {
                case .low: return "Quick evaluation"
                case .medium: return "Basic analysis"
                case .high: return "Detailed analysis with stakeholder input"
                }
            }
        }
    }
    
    struct Evaluation: Codable {
        var criteria: [EvaluationCriterion]
        var scores: [UUID: Score]
        
        struct Score: Codable {
            var rating: Double
            var confidence: Double
            var notes: String?
        }
        
        var isComplete: Bool {
            guard !criteria.isEmpty else { return false }
            return criteria.allSatisfy { criterion in
                scores[criterion.id] != nil
            }
        }
    }
    
    struct Insight: Codable {
        var type: InsightType
        var message: String
        var recommendation: String?
        
        enum InsightType: String, Codable {
            case pattern
            case bias
            case suggestion
            case warning
        }
    }
    
    struct ConfidenceMetrics: Codable {
        let dataQuality: Double
        let biasAwareness: Double
        let stakeholderCoverage: Double
        let criteriaCompleteness: Double
        
        var overallConfidence: Double {
            (dataQuality + biasAwareness + stakeholderCoverage + criteriaCompleteness) / 4.0
        }
    }
}

enum DecisionState: String, Codable {
    case empty
    case incomplete
    case ready
    case analyzed
}

private enum CodingKeys: String, CodingKey {
    case id, title, description, context, options, criteria
    case weights, evaluation, insights, pairwiseComparisons
    case analysisResults, state, created, modified
}

struct EvaluationCriterion: Codable {
    let id: UUID
    var name: String
    var weight: Double
    var description: String?
}

// Add this extension after the main Decision struct
extension Decision {
    func normalizeWeights() -> [UUID: Double] {
        let totalWeight = weights.values.reduce(0.0, +)
        guard totalWeight > 0 else { return [:] }
        
        return weights.mapValues { $0 / totalWeight }
    }
    
    func validateWeights() -> Bool {
        let totalWeight = weights.values.reduce(0.0, +)
        return abs(totalWeight - 1.0) < 0.001 && weights.values.allSatisfy { $0 >= 0 }
    }
}

extension Decision {
    init(title: String, description: String? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.context = DecisionContext(
            timeframe: .immediate,
            impact: .medium,
            reversibility: true
        )
        self.options = []
        self.criteria = []
        self.weights = [:]
        self.evaluation = Evaluation(criteria: [], scores: [:])
        self.insights = []
        self.pairwiseComparisons = nil
        self.analysisResults = nil
        self.state = .empty
        self.created = Date()
        self.modified = Date()
    }
}