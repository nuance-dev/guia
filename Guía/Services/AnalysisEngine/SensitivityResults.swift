import Foundation

struct SensitivityResults {
    let criterionSensitivities: [CriterionSensitivity]
    let criticalCriteria: [Criterion]
}

struct CriterionSensitivity {
    let criterion: Criterion
    let elasticity: Double
    let rankReversals: [RankReversal]
    let stabilityIndex: Double
}

struct RankReversal {
    let option1: Option
    let option2: Option
    let weightThreshold: Double
}

struct SensitivityData: Codable {
    // Criteria weight sensitivity (how much ranking changes with weight changes)
    var weightSensitivity: [UUID: Double]
    
    // Option score sensitivity (how much ranking changes with score changes)
    var scoreSensitivity: [UUID: Double]
    
    // Overall stability index (0-1, higher means more stable)
    var stabilityIndex: Double
    
    // Critical criteria that most affect the decision
    var criticalCriteria: [UUID]
    
    // Switching points where rankings would change
    var switchingPoints: [SwitchingPoint]
    
    struct SwitchingPoint: Codable {
        let criterionId: UUID
        let currentWeight: Double
        let switchingWeight: Double
        let affectedOptions: (UUID, UUID) // The pair of options that would switch ranks
    }
}