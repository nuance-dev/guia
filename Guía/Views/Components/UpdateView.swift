import SwiftUI

struct UpdateView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var updateChecker: UpdateChecker
    
    var body: some View {
        VStack(spacing: 20) {
            if updateChecker.isChecking {
                ProgressView("Checking for updates...")
            } else if updateChecker.updateAvailable {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Update Available")
                        .font(.system(size: 20, weight: .medium))
                    
                    Text("Version \(updateChecker.latestVersion ?? "")")
                        .foregroundColor(.secondary)
                    
                    if let notes = updateChecker.releaseNotes {
                        Text("Release Notes:")
                            .font(.headline)
                        Text(notes)
                            .font(.system(.body))
                    }
                    
                    HStack {
                        Button("Later") {
                            dismiss()
                        }
                        .keyboardShortcut(.cancelAction)
                        
                        Button("Download") {
                            if let url = updateChecker.downloadURL {
                                NSWorkspace.shared.open(url)
                            }
                            dismiss()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
            } else if let error = updateChecker.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Text("You're up to date!")
                    .font(.headline)
            }
        }
        .frame(width: 400)
        .padding(20)
    }
}