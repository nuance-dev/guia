import Foundation
import Accelerate

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
        var modifiedWeights = originalWeights
        let oldWeight = modifiedWeights[criterionIndex]
        let newWeight = max(0.0, min(1.0, oldWeight + delta))
        let weightDiff = newWeight - oldWeight
        
        // Distribute the weight difference proportionally among other criteria
        let remainingIndices = Array(0..<modifiedWeights.count).filter { $0 != criterionIndex }
        let totalRemainingWeight = remainingIndices.reduce(0.0) { $0 + modifiedWeights[$1] }
        
        for index in remainingIndices {
            let proportion = modifiedWeights[index] / totalRemainingWeight
            modifiedWeights[index] -= weightDiff * proportion
        }
        
        modifiedWeights[criterionIndex] = newWeight
        
        return modifiedWeights
    }
    
    private func calculateNewScores(
        optionScores: [[Double]],
        weights: [Double]
    ) -> [Double] {
        let n = optionScores.count
        var finalScores = [Double](repeating: 0.0, count: n)
        
        // Convert 2D array to row-major format for BLAS
        let flattenedScores = optionScores.flatMap { $0 }
        
        // Use Accelerate framework for matrix-vector multiplication
        vDSP_mmulD(flattenedScores, 1,
                   weights, 1,
                   &finalScores, 1,
                   UInt(n), 1, UInt(weights.count))
        
        // Normalize scores to [0,1] range
        let maxScore = finalScores.max() ?? 1.0
        vDSP_vsdivD(finalScores, 1, 
                    [maxScore], 
                    &finalScores, 1, 
                    UInt(finalScores.count))
        
        return finalScores
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