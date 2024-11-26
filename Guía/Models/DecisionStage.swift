import Foundation

enum DecisionStage: Int, CaseIterable, Identifiable {
    case define
    case options
    case criteria
    case compare
    case result
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .define: return "Define"
        case .options: return "Options"
        case .criteria: return "Criteria"
        case .compare: return "Compare"
        case .result: return "Result"
        }
    }
    
    var description: String {
        switch self {
        case .define: return "What are you deciding?"
        case .options: return "What are your choices?"
        case .criteria: return "What matters most?"
        case .compare: return "How do they compare?"
        case .result: return "Here's your answer"
        }
    }
    
    var systemImage: String {
        switch self {
        case .define: return "sparkles"
        case .options: return "square.stack.3d.up"
        case .criteria: return "slider.horizontal.below.rectangle"
        case .compare: return "chart.bar.xaxis"
        case .result: return "checkmark.circle.fill"
        }
    }
    
    var accentColor: String {
        switch self {
        case .define: return "indigo"
        case .options: return "blue"
        case .criteria: return "purple"
        case .compare: return "orange"
        case .result: return "green"
        }
    }
    
    var hint: String {
        switch self {
        case .define: return "Be specific about what you're trying to decide"
        case .options: return "Add 2-3 clear options you're considering"
        case .criteria: return "What factors matter most in this decision?"
        case .compare: return "Rate how each option meets your criteria"
        case .result: return "Here's what the analysis suggests"
        }
    }
    
    var progressValue: Double {
        switch self {
        case .define: return 0.2
        case .options: return 0.4
        case .criteria: return 0.6
        case .compare: return 0.8
        case .result: return 1.0
        }
    }
} 