import Foundation

// MARK: - Sensitivity Data
struct SensitivityData: Codable {
    var weightSensitivity: [UUID: Double] // Criteria ID to sensitivity score
    var scoreSensitivity: [UUID: Double]  // Option ID to sensitivity score
    var stabilityIndex: Double            // Overall stability of the analysis
    var criticalCriteria: [UUID]          // Critical criteria that most affect the decision
    var switchingPoints: [SwitchingPoint]   // Switching points where rankings would change
    
    struct SwitchingPoint: Codable {
        let criterionId: UUID
        let currentWeight: Double
        let switchingWeight: Double
        let affectedOptions: (first: UUID, second: UUID) // The pair of options that would switch ranks
        
        enum CodingKeys: String, CodingKey {
            case criterionId
            case currentWeight
            case switchingWeight
            case affectedOptions
        }
        
        // Custom encoding for tuple
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(criterionId, forKey: .criterionId)
            try container.encode(currentWeight, forKey: .currentWeight)
            try container.encode(switchingWeight, forKey: .switchingWeight)
            try container.encode([affectedOptions.first, affectedOptions.second], forKey: .affectedOptions)
        }
        
        // Custom decoding for tuple
        init(from decoder: Decoder) throws {
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
}