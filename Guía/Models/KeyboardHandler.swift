import SwiftUI

class KeyboardHandler: ObservableObject {
    @Published var canProgress = false
    var onEnterPressed: (() -> Void)?
    var onCommandEnterPressed: (() -> Void)?
    var onItemAdd: (() -> Void)?
    
    init() {
        setupKeyboardMonitoring()
    }
    
    private func setupKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Command + Enter to advance step
            if event.modifierFlags.contains(.command) && event.keyCode == 36 {
                self?.onCommandEnterPressed?()
                return nil
            }
            
            // Plain Enter for adding items
            if event.keyCode == 36 && !event.modifierFlags.contains(.command) {
                if self?.canProgress == true {
                    self?.onEnterPressed?()
                } else {
                    self?.onItemAdd?()
                }
                return nil
            }
            return event
        }
    }
    
    func updateProgressibility(_ canProgress: Bool) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.canProgress = canProgress
        }
    }
} 