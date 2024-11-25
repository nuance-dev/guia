import Foundation

struct StageAnalysis {
    let requiresStakeholderAnalysis: Bool
    let complexityScore: Double
    let hasConflictingCriteria: Bool
    
    init(
        requiresStakeholderAnalysis: Bool = false,
        complexityScore: Double = 0.0,
        hasConflictingCriteria: Bool = false
    ) {
        self.requiresStakeholderAnalysis = requiresStakeholderAnalysis
        self.complexityScore = complexityScore
        self.hasConflictingCriteria = hasConflictingCriteria
    }
} 