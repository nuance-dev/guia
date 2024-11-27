import SwiftUI

class DecisionFlowManager: ObservableObject {
    enum DecisionStep: CaseIterable {
        case initial
        case optionEntry
        case factorCollection
        case weighting
        case scoring
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
    @Published var showResetConfirmation = false
    
    var keyboardHandler: KeyboardHandler?
    
    init() {
        setupKeyboardHandler()
        setupEscapeKeyMonitoring()
        updateNavigationState()
    }
    
    private func setupKeyboardHandler() {
        keyboardHandler = KeyboardHandler()
        
        keyboardHandler?.onEnterPressed = { [weak self] in
            self?.handleEnterPress()
        }
        
        keyboardHandler?.onCommandEnterPressed = { [weak self] in
            self?.advanceStep()
        }
        
        keyboardHandler?.onTabPressed = { [weak self] in
            self?.handleTabPress()
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
    
    private func handleTabPress() {
        // Handle tab navigation based on current step
        // This can be customized per step if needed
    }
    
    func updateProgressibility(_ canProgress: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.canProgress = canProgress
            
            // Convert current step to KeyboardHandler.DecisionStep
            let step: KeyboardHandler.DecisionStep
            switch currentStep {
            case .initial: step = .initial
            case .optionEntry: step = .optionEntry
            case .factorCollection: step = .factorCollection
            case .weighting: step = .weighting
            case .scoring: step = .scoring
            case .analysis: step = .analysis
            }
            
            keyboardHandler?.updateState(
                step: step,
                canProgress: canProgress,
                canAddMore: currentStep == .optionEntry,
                isCompareMode: currentStep == .scoring
            )
        }
    }
    
    var currentHelpTip: String {
        switch currentStep {
        case .initial:
            return "Pro tip: Frame your decision as a specific question - it helps clarify your true objective"
        case .optionEntry:
            return "Pro tip: Consider unconventional alternatives that challenge your initial assumptions"
        case .factorCollection:
            return "Pro tip: Include both quantifiable factors (time, money) and qualitative ones (happiness, growth)"
        case .weighting:
            return "Pro tip: Assign higher weights to factors that align with your long-term values and goals"
        case .scoring:
            return "Pro tip: Score each option objectively - imagine giving advice to a friend"
        case .analysis:
            return "Pro tip: The best choice often balances both rational analysis and emotional alignment"
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
        case .scoring: return "Score Options"
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
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = CGFloat(currentIndex) / CGFloat(steps.count - 1)
            }
        }
    }
    
    private func updateNavigationState() {
        withAnimation(.easeInOut(duration: 0.3)) {
            canGoBack = currentStep.previousStep != nil
            canProgress = false // Reset progress state on step change
            
            // Set initial state based on current step
            switch currentStep {
            case .initial:
                keyboardHandler?.updateState(
                    step: .initial,
                    canProgress: false,
                    canAddMore: false
                )
            case .optionEntry:
                keyboardHandler?.updateState(
                    step: .optionEntry,
                    canProgress: false,
                    canAddMore: true
                )
            case .scoring:
                keyboardHandler?.updateState(
                    step: .scoring,
                    canProgress: false,
                    canAddMore: false,
                    isCompareMode: true
                )
            default:
                keyboardHandler?.updateState(
                    step: .factorCollection,
                    canProgress: false
                )
            }
        }
    }
    
    func resetFlow() {
        withAnimation(.spring(response: 0.3)) {
            currentStep = .initial
            progress = 0.0
            canProgress = false
            canGoBack = false
            keyboardHandler?.updateState(step: .optionEntry, canProgress: false, canAddMore: true)
        }
    }
    
    func showResetAlert() {
        showResetConfirmation = true
    }
} 
