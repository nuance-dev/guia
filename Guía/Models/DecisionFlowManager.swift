import SwiftUI

class DecisionFlowManager: ObservableObject {
    enum DecisionStep: CaseIterable {
        case initial
        case optionEntry
        case factorCollection
        case weighting
        case analysis
        
        var nextStep: DecisionStep? {
            let allCases = DecisionStep.allCases
            guard let currentIndex = allCases.firstIndex(of: self),
                  currentIndex + 1 < allCases.count else { return nil }
            return allCases[currentIndex + 1]
        }
        
        var previousStep: DecisionStep? {
            let allCases = DecisionStep.allCases
            guard let currentIndex = allCases.firstIndex(of: self),
                  currentIndex > 0 else { return nil }
            return allCases[currentIndex - 1]
        }
    }
    
    @Published var currentStep: DecisionStep = .initial
    @Published var showHelp = false
    @Published var progress: CGFloat = 0.0
    @Published var canProgress = false
    @Published var canGoBack = false
    
    private var keyboardHandler: KeyboardHandler?
    
    init() {
        setupKeyboardHandler()
        setupEscapeKeyMonitoring()
        updateNavigationState()
    }
    
    private func setupKeyboardHandler() {
        keyboardHandler = KeyboardHandler()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Command + Enter to advance step
            if event.modifierFlags.contains(.command) && event.keyCode == 36 {
                self?.advanceStep()
                return nil
            }
            return event
        }
        
        keyboardHandler?.onEnterPressed = { [weak self] in
            self?.handleEnterPress()
        }
    }
    
    private func setupEscapeKeyMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC key
                self?.goBack()
                return nil
            }
            return event
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
    
    func goBack() {
        guard canGoBack, let previousStep = currentStep.previousStep else { return }
        withAnimation(.spring(response: 0.3)) {
            currentStep = previousStep
            updateProgress()
            updateNavigationState()
        }
    }
    
    func advanceStep() {
        guard let nextStep = currentStep.nextStep else { return }
        withAnimation(.spring(response: 0.3)) {
            currentStep = nextStep
            updateProgress()
            updateNavigationState()
        }
    }
    
    private func updateProgress() {
        let steps = DecisionStep.allCases
        if let currentIndex = steps.firstIndex(of: currentStep) {
            progress = CGFloat(currentIndex) / CGFloat(steps.count - 1)
        }
    }
    
    private func updateNavigationState() {
        canGoBack = currentStep.previousStep != nil
        // Other navigation state updates...
    }
} 