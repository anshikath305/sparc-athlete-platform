import SwiftUI

@main
struct MyApp: App {
    @ObservedObject var settings = SettingsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(settings.themeSelection == 0 ? nil : (settings.themeSelection == 1 ? .light : .dark))
        }
    }
}
