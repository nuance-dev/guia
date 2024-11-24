import Foundation

final class SensitivityAnalyzer {
    // MARK: - Properties
    private let ahpAnalyzer: AHPAnalyzer
    
    // MARK: - Public Methods
    func analyzeSensitivity(
        originalResults: AHPResults,
        criteria: [Criterion],
        options: [Option],
        perturbationRange: ClosedRange<Double> = -0.2...0.2,
        steps: Int = 10
    ) -> SensitivityResults {
        var sensitivityData: [CriterionSensitivity] = []
        
        // Analyze each criterion's impact
        for (criterionIndex, criterion) in criteria.enumerated() {
            var weightVariations: [WeightVariation] = []
            
            // Calculate results for different weight variations
            for step in 0...steps {
                let delta = perturbationRange.interpolated(step: step, steps: steps)
                let modifiedWeights = modifyCriterionWeight(
                    originalWeights: originalResults.criteriaWeights,
                    criterionIndex: criterionIndex,
                    delta: delta
                )
                
                // Calculate new scores with modified weights
                let newScores = calculateNewScores(
                    optionScores: originalResults.optionScores,
                    weights: modifiedWeights
                )
                
                weightVariations.append(
                    WeightVariation(
                        weightDelta: delta,
                        scores: newScores
                    )
                )
            }
            
            // Calculate sensitivity metrics
            let sensitivity = calculateSensitivityMetrics(
                criterion: criterion,
                variations: weightVariations
            )
            
            sensitivityData.append(sensitivity)
        }
        
        return SensitivityResults(
            criterionSensitivities: sensitivityData,
            criticalCriteria: identifyCriticalCriteria(sensitivityData)
        )
    }
    
    // MARK: - Private Methods
    private func modifyCriterionWeight(
        originalWeights: [Double],
        criterionIndex: Int,
        delta: Double
    ) -> [Double] {
        // TODO: Implement weight modification logic
        // Ensure weights still sum to 1.0
    }
    
    private func calculateNewScores(
        optionScores: [[Double]],
        weights: [Double]
    ) -> [Double] {
        // TODO: Implement score recalculation
    }
    
    private func calculateSensitivityMetrics(
        criterion: Criterion,
        variations: [WeightVariation]
    ) -> CriterionSensitivity {
        // TODO: Implement sensitivity metrics calculation
    }
}

// MARK: - Sensitivity Results
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