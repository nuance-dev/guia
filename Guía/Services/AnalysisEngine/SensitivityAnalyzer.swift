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
        // Calculate baseline rankings
        let baselineRankings = analyzer.calculateRankings()
        
        var sensitivityScores: [Double] = []
        var rankingChanges: [WeightVariationImpact] = []
        
        // Analyze each weight variation
        for variation in variations {
            // Create a temporary copy of weights with the variation applied
            var modifiedWeights = criterion.weights
            modifiedWeights[variation.criterionIndex] *= (1.0 + variation.delta)
            
            // Normalize modified weights
            let sum = modifiedWeights.reduce(0, +)
            modifiedWeights = modifiedWeights.map { $0 / sum }
            
            // Calculate new rankings with modified weights
            let newRankings = analyzer.calculateRankings(withModifiedWeights: modifiedWeights)
            
            // Calculate ranking stability score (0-1, where 1 means no change)
            let stabilityScore = calculateStabilityScore(
                original: baselineRankings,
                modified: newRankings
            )
            sensitivityScores.append(stabilityScore)
            
            // Record if this variation caused any rank changes
            if stabilityScore < 1.0 {
                rankingChanges.append(WeightVariationImpact(
                    variation: variation,
                    originalRanking: baselineRankings,
                    modifiedRanking: newRankings
                ))
            }
        }
        
        return CriterionSensitivity(
            criterionId: criterion.id,
            sensitivityScore: sensitivityScores.reduce(0, +) / Double(sensitivityScores.count),
            rankingChanges: rankingChanges
        )
    }
    
    private func calculateStabilityScore(original: [Double], modified: [Double]) -> Double {
        var changes = 0
        let n = original.count
        
        // Compare each pair of alternatives
        for i in 0..<n {
            for j in (i+1)..<n {
                // Check if relative ranking between i and j changed
                let originalComparison = original[i] > original[j]
                let modifiedComparison = modified[i] > modified[j]
                
                if originalComparison != modifiedComparison {
                    changes += 1
                }
            }
        }
        
        // Calculate stability score (1 - normalized changes)
        let maxPossibleChanges = (n * (n - 1)) / 2
        return 1.0 - (Double(changes) / Double(maxPossibleChanges))
    }
    
    // Add initializer
    init(ahpAnalyzer: AHPAnalyzer = AHPAnalyzer()) {
        self.ahpAnalyzer = ahpAnalyzer
    }
    
    // Add missing types
    private struct WeightVariation {
        let delta: Double
        let scores: [Double]
    }
    
    private struct WeightVariationImpact {
        let variation: WeightVariation
        let originalRanking: [Double]
        let modifiedRanking: [Double]
    }
    
    // Add extension for interpolation
    private extension ClosedRange where Bound == Double {
        func interpolated(step: Int, steps: Int) -> Double {
            let progress = Double(step) / Double(steps)
            return lowerBound + (upperBound - lowerBound) * progress
        }
    }
    
    // Add missing method
    private func identifyCriticalCriteria(_ sensitivities: [CriterionSensitivity]) -> [Criterion] {
        let threshold = 0.1 // Sensitivity threshold for critical criteria
        return sensitivities
            .filter { $0.elasticity > threshold }
            .map { $0.criterion }
    }
}

