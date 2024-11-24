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