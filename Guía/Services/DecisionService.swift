import Foundation

class DecisionService {
    static func analyzeOptions(_ options: [DecisionOption]) async -> DecisionAnalysis {
        // Simulate complex analysis
        await Task.sleep(1_500_000_000) // 1.5 seconds
        
        // Calculate scores based on pros and cons
        var scoredOptions = options.map { option in
            var option = option
            let prosWeight = 1.2
            let consWeight = 1.0
            
            option.score = Double(option.pros.count) * prosWeight - Double(option.cons.count) * consWeight
            return option
        }
        
        // Sort by score
        scoredOptions.sort { $0.score > $1.score }
        
        // Generate natural language reasoning
        let winner = scoredOptions[0]
        let runnerUp = scoredOptions.count > 1 ? scoredOptions[1] : nil
        
        var reasoning: [String] = []
        
        // Add main recommendation
        let confidence = calculateConfidence(winner: winner, runnerUp: runnerUp)
        
        // Generate reasoning points
        if let runnerUp = runnerUp {
            let scoreDifference = abs(winner.score - runnerUp.score)
            
            if scoreDifference > 2 {
                reasoning.append("There's a clear advantage in favor of '\(winner.title)'")
            } else {
                reasoning.append("While both options have merit, '\(winner.title)' has a slight edge")
            }
        }
        
        // Add specific points about the winner
        if !winner.pros.isEmpty {
            reasoning.append("Key strengths of '\(winner.title)': \(winner.pros[0])")
        }
        
        // Add balanced perspective
        if !winner.cons.isEmpty {
            reasoning.append("Consider this trade-off: \(winner.cons[0])")
        }
        
        let recommendation = generateRecommendation(winner: winner, confidence: confidence)
        
        return DecisionAnalysis(
            recommendation: recommendation,
            confidence: confidence,
            reasoning: reasoning,
            timestamp: Date()
        )
    }
    
    private static func calculateConfidence(winner: DecisionOption, runnerUp: DecisionOption?) -> Double {
        var confidence = 0.7 // Base confidence
        
        if let runnerUp = runnerUp {
            let scoreDifference = abs(winner.score - runnerUp.score)
            confidence += min(scoreDifference * 0.1, 0.2) // Max 0.2 boost from score difference
        }
        
        // Adjust based on pros and cons
        if !winner.pros.isEmpty {
            confidence += 0.05
        }
        if !winner.cons.isEmpty {
            confidence -= 0.05
        }
        
        return min(max(confidence, 0.0), 1.0)
    }
    
    private static func generateRecommendation(winner: DecisionOption, confidence: Double) -> String {
        let prefix: String
        if confidence > 0.8 {
            prefix = "Confidently recommending"
        } else if confidence > 0.6 {
            prefix = "Leaning towards"
        } else {
            prefix = "Slightly favoring"
        }
        
        return "\(prefix) '\(winner.title)'"
    }
} 