import SwiftUI

private struct IsAdvancedModeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isAdvancedMode: Bool {
        get { self[IsAdvancedModeKey.self] }
        set { self[IsAdvancedModeKey.self] = newValue }
    }
} 