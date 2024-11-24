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
        let affectedOptions: (UUID, UUID) // The pair of options that would switch ranks
    }
}