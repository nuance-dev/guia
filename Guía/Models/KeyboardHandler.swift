import SwiftUI

class KeyboardHandler: ObservableObject {
    @Published var canProgress = false
    var onEnterPressed: (() -> Void)?
    
    init() {
        setupKeyboardMonitoring()
    }
    
    private func setupKeyboardMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 36 { // Enter key
                if self?.canProgress == true {
                    self?.onEnterPressed?()
                    return nil
                }
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