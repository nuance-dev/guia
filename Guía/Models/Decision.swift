import Foundation
import CoreData

// MARK: - Decision Model
public struct Decision: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String?
    public var context: DecisionContext
    public var options: [OptionModel]
    public var criteria: [UnifiedCriterion]
    public var weights: [UUID: Double]
    public var evaluation: Evaluation
    public var insights: [Insight]
    public var pairwiseComparisons: [[Double]]?
    public var analysisResults: AnalysisResults?
    public var state: DecisionState
    public var created: Date
    public var modified: Date
    
    // MARK: - Insight Model
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
    
    // MARK: - Hashable Conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Decision, rhs: Decision) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Weight Management
    public func normalizeWeights() -> [UUID: Double] {
        let totalWeight = weights.values.reduce(0.0, +)
        guard totalWeight > 0 else { return [:] }
        return weights.mapValues { $0 / totalWeight }
    }
    
    public func validateWeights() -> Bool {
        let totalWeight = weights.values.reduce(0.0, +)
        return abs(totalWeight - 1.0) < 0.001 && weights.values.allSatisfy { $0 >= 0 }
    }
    
    // MARK: - Evaluation
    public struct Evaluation: Codable {
        public var criteria: [UnifiedCriterion]
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
        
        public init(criteria: [UnifiedCriterion], scores: [UUID: Score]) {
            self.criteria = criteria
            self.scores = scores
        }
    }
    
    // MARK: - Context
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
    
    // MARK: - Confidence Metrics
    public struct ConfidenceMetrics: Codable {
        public var dataQuality: Double
        public var biasAwareness: Double
        public var stakeholderCoverage: Double
        public var criteriaCompleteness: Double
        
        public var overallConfidence: Double {
            return (dataQuality + biasAwareness + stakeholderCoverage + criteriaCompleteness) / 4.0
        }
        
        public init(dataQuality: Double, biasAwareness: Double, stakeholderCoverage: Double, criteriaCompleteness: Double) {
            self.dataQuality = dataQuality
            self.biasAwareness = biasAwareness
            self.stakeholderCoverage = stakeholderCoverage
            self.criteriaCompleteness = criteriaCompleteness
        }
    }
    
    // MARK: - Initialize
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        context: DecisionContext = DecisionContext(timeframe: .immediate, impact: .medium, reversibility: true),
        options: [OptionModel] = [],
        criteria: [UnifiedCriterion] = [],
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

// MARK: - Supporting Types
public enum DecisionState: String, Codable {
    case empty
    case incomplete
    case ready
    case analyzed
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
