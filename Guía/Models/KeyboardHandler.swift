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
    
    var onEnterPressed: (() -> Void)?
    var onCommandEnterPressed: (() -> Void)?
    var onItemAdd: (() -> Void)?
    var onTabPressed: (() -> Void)?
    
    init() {
        setupKeyboardMonitoring()
    }
    
    private func setupKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self else { return event }
            
            // Command + Enter always tries to progress
            if event.modifierFlags.contains(.command) && event.keyCode == 36 {
                if self.canProgress {
                    self.onCommandEnterPressed?()
                }
                return nil
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
                    // In option entry, enter adds new item
                    if self.canAddMore {
                        self.onItemAdd?()
                    }
                default:
                    break
                }
                return nil
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
} 