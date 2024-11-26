import Foundation
import CoreData

// MARK: - Decision Model
public struct Decision: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var context: DecisionContext
    public var options: [OptionModel]
    public var criteria: [BasicCriterion]
    public var weights: [UUID: Double]
    public var evaluation: Evaluation
    public var insights: [Insight]
    public var pairwiseComparisons: [[Double]]?
    public var analysisResults: AnalysisResults?
    public var state: DecisionState
    public var created: Date
    public var modified: Date
    
    // MARK: - Hashable Conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Decision, rhs: Decision) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        context = try container.decode(DecisionContext.self, forKey: .context)
        options = try container.decode([OptionModel].self, forKey: .options)
        criteria = try container.decode([BasicCriterion].self, forKey: .criteria)
        weights = try container.decode([UUID: Double].self, forKey: .weights)
        evaluation = try container.decode(Evaluation.self, forKey: .evaluation)
        insights = try container.decode([Insight].self, forKey: .insights)
        pairwiseComparisons = try container.decodeIfPresent([[Double]].self, forKey: .pairwiseComparisons)
        analysisResults = try container.decodeIfPresent(AnalysisResults.self, forKey: .analysisResults)
        state = try container.decode(DecisionState.self, forKey: .state)
        created = try container.decode(Date.self, forKey: .created)
        modified = try container.decode(Date.self, forKey: .modified)
    }
    
    public func encode(to encoder: Encoder) throws {
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
    
    public struct DecisionContext: Codable {
        public var timeframe: Timeframe
        public var impact: Impact
        public var reversibility: Bool
        
        public enum Timeframe: String, Codable {
            case immediate
            case shortTerm
            case longTerm
            
            public var suggestedApproach: String {
                switch self {
                case .immediate: return "Focus on gut feeling and quick pros/cons"
                case .shortTerm: return "Balance data with intuition"
                case .longTerm: return "Prioritize thorough analysis and future implications"
                }
            }
        }
        
        public enum Impact: String, Codable {
            case low, medium, high
        }
        
        public init(timeframe: Timeframe, impact: Impact, reversibility: Bool) {
            self.timeframe = timeframe
            self.impact = impact
            self.reversibility = reversibility
        }
    }
    
    public struct Evaluation: Codable {
        public var criteria: [EvaluationCriterion]
        public var scores: [UUID: Score]
        
        public struct Score: Codable {
            public var rating: Double
            public var confidence: Double
            public var notes: String?
            
            public init(rating: Double, confidence: Double, notes: String? = nil) {
                self.rating = rating
                self.confidence = confidence
                self.notes = notes
            }
        }
        
        public var isComplete: Bool {
            guard !criteria.isEmpty else { return false }
            return criteria.allSatisfy { criterion in
                scores[criterion.id] != nil
            }
        }
        
        public init(criteria: [EvaluationCriterion], scores: [UUID: Score]) {
            self.criteria = criteria
            self.scores = scores
        }
    }
    
    public struct Insight: Codable {
        public var type: InsightType
        public var message: String
        public var recommendation: String?
        
        public enum InsightType: String, Codable {
            case pattern
            case bias
            case suggestion
            case warning
        }
        
        public init(type: InsightType, message: String, recommendation: String? = nil) {
            self.type = type
            self.message = message
            self.recommendation = recommendation
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

public enum DecisionState: String, Codable {
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

public struct EvaluationCriterion: Codable {
    public let id: UUID
    public var name: String
    public var weight: Double
    public var description: String?
    
    public init(id: UUID = UUID(), name: String, weight: Double = 1.0, description: String? = nil) {
        self.id = id
        self.name = name
        self.weight = weight
        self.description = description
    }
}

// MARK: - Option Model
public struct OptionModel: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var description: String?
    public var scores: [UUID: Double]
    public var notes: String?
    
    public init(id: UUID = UUID(), name: String, description: String? = nil, scores: [UUID: Double] = [:], notes: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.scores = scores
        self.notes = notes
    }
}

// MARK: - Criterion Model
public struct CriterionModel: Identifiable, Codable, Criterion {
    public let id: UUID
    public var name: String
    public var description: String?
    public var weight: Double
    
    public init(id: UUID = UUID(), name: String, description: String? = nil, weight: Double = 1.0) {
        self.id = id
        self.name = name
        self.description = description
        self.weight = weight
    }
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
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        context: DecisionContext = DecisionContext(timeframe: .immediate, impact: .medium, reversibility: true),
        options: [OptionModel] = [],
        criteria: [BasicCriterion] = [],
        weights: [UUID: Double] = [:],
        evaluation: Evaluation = Evaluation(criteria: [], scores: [:]),
        insights: [Insight] = [],
        pairwiseComparisons: [[Double]]? = nil,
        analysisResults: AnalysisResults? = nil,
        state: DecisionState = .empty,
        created: Date = Date(),
        modified: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.context = context
        self.options = options
        self.criteria = criteria
        self.weights = weights
        self.evaluation = evaluation
        self.insights = insights
        self.pairwiseComparisons = pairwiseComparisons
        self.analysisResults = analysisResults
        self.state = state
        self.created = created
        self.modified = modified
    }
}
