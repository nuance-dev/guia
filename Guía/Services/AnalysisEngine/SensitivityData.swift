import Foundation

// MARK: - Sensitivity Data
public struct SensitivityData: Codable {
    public var weightSensitivity: [UUID: Double] // Criteria ID to sensitivity score
    public var scoreSensitivity: [UUID: Double]  // Option ID to sensitivity score
    public var stabilityIndex: Double            // Overall stability of the analysis
    public var criticalCriteria: [UUID]          // Critical criteria that most affect the decision
    public var switchingPoints: [SwitchingPoint]   // Switching points where rankings would change
    
    public struct SwitchingPoint: Codable {
        public let criterionId: UUID
        public let currentWeight: Double
        public let switchingWeight: Double
        public let affectedOptions: (UUID, UUID)
        
        // Add regular initializer
        public init(criterionId: UUID, currentWeight: Double, switchingWeight: Double, affectedOptions: (UUID, UUID)) {
            self.criterionId = criterionId
            self.currentWeight = currentWeight
            self.switchingWeight = switchingWeight
            self.affectedOptions = affectedOptions
        }
        
        // Keep existing Codable implementation
        enum CodingKeys: String, CodingKey {
            case criterionId
            case currentWeight
            case switchingWeight
            case affectedOptions
        }
        
        // Custom encoding for tuple
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(criterionId, forKey: .criterionId)
            try container.encode(currentWeight, forKey: .currentWeight)
            try container.encode(switchingWeight, forKey: .switchingWeight)
            try container.encode([affectedOptions.0, affectedOptions.1], forKey: .affectedOptions)
        }
        
        // Custom decoding for tuple
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            criterionId = try container.decode(UUID.self, forKey: .criterionId)
            currentWeight = try container.decode(Double.self, forKey: .currentWeight)
            switchingWeight = try container.decode(Double.self, forKey: .switchingWeight)
            let options = try container.decode([UUID].self, forKey: .affectedOptions)
            guard options.count == 2 else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Affected options must contain exactly 2 UUIDs"
                ))
            }
            affectedOptions = (options[0], options[1])
        }
    }
    
    public init(weightSensitivity: [UUID: Double], scoreSensitivity: [UUID: Double], stabilityIndex: Double, criticalCriteria: [UUID], switchingPoints: [SwitchingPoint]) {
        self.weightSensitivity = weightSensitivity
        self.scoreSensitivity = scoreSensitivity
        self.stabilityIndex = stabilityIndex
        self.criticalCriteria = criticalCriteria
        self.switchingPoints = switchingPoints
    }
}