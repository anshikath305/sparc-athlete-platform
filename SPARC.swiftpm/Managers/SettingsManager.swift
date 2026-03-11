import Foundation
import SwiftUI

@MainActor
final class SettingsManager: ObservableObject {
    @AppStorage("sparc_theme") var themeSelection: Int = 0 // 0: System, 1: Light, 2: Dark
    @AppStorage("sparc_motivation_enabled") var motivationEnabled: Bool = true
    @AppStorage("sparc_notifications_enabled") var notificationsEnabled: Bool = false
    
    @MainActor static let shared = SettingsManager()
}
