import SwiftUI

class KeyboardHandler: ObservableObject {
    enum DecisionStep {
        case initial
        case optionEntry
        case factorCollection
        case weighting
        case scoring
        case analysis
    }
    
    @Published var canProgress = false
    @Published var canAddMore = true
    @Published var isCompareMode = false
    @Published var currentStep: DecisionStep = .initial
    @Published var activeOptionField = 0
    
    var onEnterPressed: (() -> Void)?
    var onCommandEnterPressed: (() -> Void)?
    var onItemAdd: (() -> Void)?
    var onTabPressed: (() -> Void)?
    var onOptionSubmit: ((Int) -> Void)?
    
    init() {
        setupKeyboardMonitoring()
    }
    
    private func setupKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            // Command + Enter always tries to progress if possible
            if event.modifierFlags.contains(.command) && event.keyCode == 36 {
                if self.canProgress {
                    self.onCommandEnterPressed?()
                    return nil
                }
                return event
            }
            
            // Tab key for field navigation
            if event.keyCode == 48 {
                self.onTabPressed?()
                return nil
            }
            
            // Plain Enter behavior
            if event.keyCode == 36 && !event.modifierFlags.contains(.command) {
                switch currentStep {
                case .optionEntry:
                    // Submit current option if valid
                    self.onOptionSubmit?(self.activeOptionField)
                    return nil
                case .scoring:
                    // In scoring, if we can progress, enter advances
                    if self.canProgress {
                        self.onEnterPressed?()
                        return nil
                    }
                default:
                    // For other steps, enter advances if we can progress
                    if self.canProgress {
                        self.onEnterPressed?()
                        return nil
                    }
                }
            }
            
            return event
        }
    }
    
    func updateState(step: DecisionStep, canProgress: Bool, canAddMore: Bool = true, isCompareMode: Bool = false) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.currentStep = step
            self.canProgress = canProgress
            self.canAddMore = canAddMore
            self.isCompareMode = isCompareMode
        }
    }
    
    func setActiveOptionField(_ field: Int) {
        self.activeOptionField = field
    }
} 