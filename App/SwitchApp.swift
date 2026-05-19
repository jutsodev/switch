import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@main
struct SwitchApp: App {

    @StateObject private var settings = SettingsStore()
    @StateObject private var store = ConversationStore()
    private let api = APIClient()

    init() {
        // Force dark appearance everywhere.
        #if canImport(UIKit)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.forEach { $0.overrideUserInterfaceStyle = .dark }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store, settings: settings, api: api)
                .environmentObject(settings)
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Color(red: 0.95, green: 0.55, blue: 0.92))
        }
    }
}
