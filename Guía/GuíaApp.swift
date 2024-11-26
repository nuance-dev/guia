import SwiftUI

@main
struct GuiaApp: App {
    @StateObject private var decisionEngine = DecisionEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(decisionEngine)
                .preferredColorScheme(.dark)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
class DecisionEngine: ObservableObject {
    @Published var currentStep: DecisionStep = .initial
    @Published var options: [DecisionOption] = []
    @Published var analysis: DecisionAnalysis?
    @Published var isProcessing = false
    
    enum DecisionStep {
        case initial
        case inputting
        case analyzing
        case result
    }
}

struct DecisionOption: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var pros: [String] = []
    var cons: [String] = []
    var score: Double = 0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DecisionAnalysis {
    var recommendation: String
    var confidence: Double
    var reasoning: [String]
    var timestamp: Date
}

