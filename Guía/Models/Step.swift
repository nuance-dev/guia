import Foundation

enum Step: Int, CaseIterable {
    case initial
    case optionEntry
    case factorCollection
    case weighting
    case scoring
    case analysis
    
    var title: String {
        switch self {
        case .initial: return "Start"
        case .optionEntry: return "Options"
        case .factorCollection: return "Factors"
        case .weighting: return "Weight"
        case .scoring: return "Score"
        case .analysis: return "Analysis"
        }
    }
    
    var progressValue: Double {
        Double(rawValue) / Double(Step.allCases.count - 1)
    }
    
    var flowStep: DecisionFlowManager.DecisionStep {
        switch self {
        case .initial: return .initial
        case .optionEntry: return .optionEntry
        case .factorCollection: return .factorCollection
        case .weighting: return .weighting
        case .scoring: return .scoring
        case .analysis: return .analysis
        }
    }
} 