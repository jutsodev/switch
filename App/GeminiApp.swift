import SwiftUI

@main
struct SwitchApp: App {
    @StateObject var appCoordinator = AppCoordinator()
    @StateObject var apiClient = SwitchAPIClient.shared
    @StateObject var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                
                ContentView()
                    .environmentObject(appCoordinator)
                    .environmentObject(apiClient)
                    .environmentObject(themeManager)
                    .preferredColorScheme(.dark)
            }
        }
    }
}

class AppCoordinator: NSObject, ObservableObject {
    @Published var navigationStack: [NavigationDestination] = []
    @Published var presentedSheet: SheetDestination? = nil
    
    func pushNavigation(_ destination: NavigationDestination) {
        navigationStack.append(destination)
    }
    
    func popNavigation() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
        }
    }
    
    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
}

enum NavigationDestination: Hashable {
    case chatDetail(String)
    case settings
    case about
}

enum SheetDestination: Identifiable {
    case modelSelection
    case toolsMenu
    case fileManager
    
    var id: String {
        switch self {
        case .modelSelection: return "modelSelection"
        case .toolsMenu: return "toolsMenu"
        case .fileManager: return "fileManager"
        }
    }
}
