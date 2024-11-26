import Foundation

struct ValidationCheck: Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let isPassing: Bool
    
    init(title: String, description: String, isPassing: Bool) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.isPassing = isPassing
    }
}

struct ValidationResults {
    let validationChecks: [ValidationCheck]
    let isValid: Bool
    
    var recommendations: [String] {
        validationChecks
            .filter { !$0.isPassing }
            .map { "Consider addressing: \($0.title)" }
    }
} 