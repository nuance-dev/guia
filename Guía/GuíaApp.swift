import SwiftUI

@main
struct GuiaApp: App {
    @StateObject private var updateChecker = UpdateChecker()
    @State private var showingUpdateSheet = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .frame(minWidth: 800, minHeight: 600)
                .background(WindowAccessor())
                .onAppear {
                    // Check for updates when app launches
                    updateChecker.checkForUpdates()
                    
                    // Set up observer for update availability
                    updateChecker.onUpdateAvailable = {
                        showingUpdateSheet = true
                    }
                }
                .sheet(isPresented: $showingUpdateSheet) {
                    UpdateView(updateChecker: updateChecker)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            
            // Add update commands to the app menu
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    showingUpdateSheet = true
                    updateChecker.checkForUpdates()
                }
                .keyboardShortcut("U", modifiers: [.command])
                
                if updateChecker.updateAvailable {
                    Button("Download Update") {
                        if let url = updateChecker.downloadURL {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
                
                Divider()
            }
        }
    }
}
