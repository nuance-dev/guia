import Foundation

// MARK: - Analysis Results
public struct AnalysisResults: Codable {
    public var rankedOptions: [RankedOption]
    public var confidenceScore: Double
    public var sensitivityData: SensitivityData
    public var method: AnalysisMethod
    public var criteria: [any Criterion]
    
    public struct RankedOption: Identifiable, Codable {
        public let id: UUID
        public let optionId: UUID
        public let score: Double
        public var rank: Int
        public var breakdownByCriteria: [UUID: Double]
        
        private enum CodingKeys: String, CodingKey {
            case id
            case optionId
            case score
            case rank
            case breakdownByCriteria
        }
        
        public init(id: UUID, optionId: UUID, score: Double, rank: Int, breakdownByCriteria: [UUID: Double]) {
            self.id = id
            self.optionId = optionId
            self.score = score
            self.rank = rank
            self.breakdownByCriteria = breakdownByCriteria
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case rankedOptions
        case confidenceScore
        case sensitivityData
        case method
        case criteria
    }
    
    public init(rankedOptions: [RankedOption], confidenceScore: Double, sensitivityData: SensitivityData, method: AnalysisMethod, criteria: [any Criterion]) {
        self.rankedOptions = rankedOptions
        self.confidenceScore = confidenceScore
        self.sensitivityData = sensitivityData
        self.method = method
        self.criteria = criteria
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rankedOptions = try container.decode([RankedOption].self, forKey: .rankedOptions)
        confidenceScore = try container.decode(Double.self, forKey: .confidenceScore)
        sensitivityData = try container.decode(SensitivityData.self, forKey: .sensitivityData)
        method = try container.decode(AnalysisMethod.self, forKey: .method)
        criteria = try container.decode([CriterionModel].self, forKey: .criteria) as [any Criterion]
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rankedOptions, forKey: .rankedOptions)
        try container.encode(confidenceScore, forKey: .confidenceScore)
        try container.encode(sensitivityData, forKey: .sensitivityData)
        try container.encode(method, forKey: .method)
        try container.encode(criteria as? [CriterionModel] ?? [], forKey: .criteria)
    }
}

