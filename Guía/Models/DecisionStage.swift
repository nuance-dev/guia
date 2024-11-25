import Foundation

enum DecisionStage: Int, CaseIterable {
    case problem
    case stakeholders
    case options
    case criteria
    case weights
    case analysis
    case refinement
    case validation
    
    var title: String {
        switch self {
        case .problem: return "Define Problem"
        case .stakeholders: return "Map Stakeholders"
        case .options: return "List Options"
        case .criteria: return "Set Criteria"
        case .weights: return "Assign Weights"
        case .analysis: return "Analyze"
        case .refinement: return "Refine"
        case .validation: return "Validate"
        }
    }
    
    var systemImage: String {
        switch self {
        case .problem: return "questionmark.circle"
        case .stakeholders: return "person.2.circle"
        case .options: return "list.bullet"
        case .criteria: return "slider.horizontal.3"
        case .weights: return "scale.3d"
        case .analysis: return "chart.bar"
        case .refinement: return "slider.horizontal.below.rectangle"
        case .validation: return "checkmark.circle"
        }
    }
} 