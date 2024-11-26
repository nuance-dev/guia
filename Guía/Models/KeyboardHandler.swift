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
            
            // Tab key for field navigation
            if event.keyCode == 48 {
                self.onTabPressed?()
                return nil
            }
            
            // Enter behavior
            if event.keyCode == 36 {
                switch currentStep {
                case .optionEntry:
                    // In option entry, plain enter adds new option, cmd+enter continues
                    if event.modifierFlags.contains(.command) {
                        if self.canProgress {
                            self.onCommandEnterPressed?()
                            return nil
                        }
                    } else {
                        self.onItemAdd?()
                        return nil
                    }
                case .scoring:
                    // In scoring, enter advances to next factor if possible
                    if !event.modifierFlags.contains(.command) {
                        self.onEnterPressed?()
                        return nil
                    }
                default:
                    // For other steps, enter advances if we can progress
                    if !event.modifierFlags.contains(.command) && self.canProgress {
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