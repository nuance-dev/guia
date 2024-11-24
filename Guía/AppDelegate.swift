import AppKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure any app-wide settings or services here
        configureAppearance()
    }
    
    // MARK: - Private Methods
    private func configureAppearance() {
        // Set up modern, minimal UI appearance for macOS
        if let window = NSApplication.shared.windows.first {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.backgroundColor = .windowBackgroundColor
        }
        
        // Configure toolbar appearance if needed
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}
