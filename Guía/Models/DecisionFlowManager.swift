import SwiftUI

class DecisionFlowManager: ObservableObject {
    enum DecisionStep {
        case initial
        case optionEntry
        case factorCollection
        case weighting
        case analysis
    }
    
    @Published var currentStep: DecisionStep = .initial
    @Published var showHelp = false
    @Published var progress: CGFloat = 0.0
    @Published var canProgress = false
    
    private var keyboardHandler: KeyboardHandler?
    
    init() {
        setupKeyboardHandler()
    }
    
    private func setupKeyboardHandler() {
        keyboardHandler = KeyboardHandler()
        keyboardHandler?.onEnterPressed = { [weak self] in
            self?.handleEnterPress()
        }
    }
    
    private func handleEnterPress() {
        guard canProgress else { return }
        advanceStep()
    }
    
    func updateProgressibility(_ canProgress: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.canProgress = canProgress
            keyboardHandler?.updateProgressibility(canProgress)
        }
    }
    
    var currentHelpTip: String {
        switch currentStep {
        case .initial:
            return "Let's help you make the right choice. Start by thinking about your options."
        case .optionEntry:
            return "Enter 2-3 options you're deciding between. Be specific but concise."
        case .factorCollection:
            return "What factors matter most in this decision? List them in order of importance."
        case .weighting:
            return "Adjust how much each factor influences your decision."
        case .analysis:
            return "Here's a detailed breakdown of your decision based on your inputs."
        }
    }
    
    var showActionButton: Bool {
        currentStep != .analysis
    }
    
    var actionButtonTitle: String {
        switch currentStep {
        case .initial: return "Start"
        case .optionEntry: return "Continue"
        case .factorCollection: return "Weight Factors"
        case .weighting: return "Analyze"
        case .analysis: return ""
        }
    }
    
    func advanceStep() {
        withAnimation(.spring(response: 0.3)) {
            switch currentStep {
            case .initial:
                currentStep = .optionEntry
                progress = 0.25
            case .optionEntry:
                currentStep = .factorCollection
                progress = 0.5
            case .factorCollection:
                currentStep = .weighting
                progress = 0.75
            case .weighting:
                currentStep = .analysis
                progress = 1.0
            case .analysis:
                break
            }
            
            // Show contextual help with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showHelp = true
                }
            }
        }
    }
} 