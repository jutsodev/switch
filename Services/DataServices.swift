import SwiftUI
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GeminiApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Core Data save error: \(error)")
            }
        }
    }
}

class LocalStorageService: NSObject, ObservableObject {
    static let shared = LocalStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    func saveString(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    func loadString(forKey key: String) -> String? {
        userDefaults.string(forKey: key)
    }
    
    func saveData(_ data: Data, forKey key: String) {
        userDefaults.set(data, forKey: key)
    }
    
    func loadData(forKey key: String) -> Data? {
        userDefaults.data(forKey: key)
    }
    
    func saveDictionary(_ dictionary: [String: Any], forKey key: String) {
        userDefaults.set(dictionary, forKey: key)
    }
    
    func loadDictionary(forKey key: String) -> [String: Any]? {
        userDefaults.dictionary(forKey: key)
    }
    
    func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func getAllDocuments() -> [URL] {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return []
        }
        
        do {
            return try fileManager.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil
            )
        } catch {
            print("Error reading documents: \(error)")
            return []
        }
    }
    
    func saveFile(_ data: Data, withName name: String) -> URL? {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(name)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    func loadFile(withName name: String) -> Data? {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(name)
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Error loading file: \(error)")
            return nil
        }
    }
    
    func deleteFile(withName name: String) -> Bool {
        guard let documentsDirectory = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return false
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(name)
        
        do {
            try fileManager.removeItem(at: fileURL)
            return true
        } catch {
            print("Error deleting file: \(error)")
            return false
        }
    }
    
    func getCacheDirectory() -> URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func getDocumentsDirectory() -> URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

class UserPreferencesService: NSObject, ObservableObject {
    static let shared = UserPreferencesService()
    
    @Published var darkModeEnabled: Bool {
        didSet {
            LocalStorageService.shared.saveString(
                darkModeEnabled ? "true" : "false",
                forKey: "darkMode"
            )
        }
    }
    
    @Published var selectedLanguage: String {
        didSet {
            LocalStorageService.shared.saveString(
                selectedLanguage,
                forKey: "language"
            )
        }
    }
    
    @Published var textSize: TextSize {
        didSet {
            LocalStorageService.shared.saveString(
                textSize.rawValue,
                forKey: "textSize"
            )
        }
    }
    
    @Published var soundEnabled: Bool {
        didSet {
            LocalStorageService.shared.saveString(
                soundEnabled ? "true" : "false",
                forKey: "sound"
            )
        }
    }
    
    @Published var hapticFeedbackEnabled: Bool {
        didSet {
            LocalStorageService.shared.saveString(
                hapticFeedbackEnabled ? "true" : "false",
                forKey: "haptic"
            )
        }
    }
    
    override init() {
        darkModeEnabled = LocalStorageService.shared.loadString(forKey: "darkMode") != "false"
        selectedLanguage = LocalStorageService.shared.loadString(forKey: "language") ?? "ru"
        
        let savedTextSize = LocalStorageService.shared.loadString(forKey: "textSize") ?? "medium"
        textSize = TextSize(rawValue: savedTextSize) ?? .medium
        
        soundEnabled = LocalStorageService.shared.loadString(forKey: "sound") != "false"
        hapticFeedbackEnabled = LocalStorageService.shared.loadString(forKey: "haptic") != "false"
    }
}

enum TextSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        case .extraLarge: return 18
        }
    }
}

class AnalyticsService: NSObject, ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var events: [AnalyticsEvent] = []
    
    func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
        let event = AnalyticsEvent(
            id: UUID().uuidString,
            name: name,
            timestamp: Date(),
            parameters: parameters ?? [:]
        )
        
        DispatchQueue.main.async {
            self.events.append(event)
        }
    }
    
    func trackScreenView(_ screenName: String) {
        trackEvent("screen_view", parameters: ["screen_name": screenName])
    }
    
    func trackUserAction(_ action: String, on component: String) {
        trackEvent("user_action", parameters: [
            "action": action,
            "component": component
        ])
    }
}

struct AnalyticsEvent: Identifiable {
    let id: String
    let name: String
    let timestamp: Date
    let parameters: [String: Any]
}

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [AppNotification] = []
    
    func scheduleNotification(
        title: String,
        message: String,
        delay: TimeInterval = 0,
        type: NotificationType = .info
    ) {
        let notification = AppNotification(
            id: UUID().uuidString,
            title: title,
            message: message,
            type: type,
            timestamp: Date()
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.notifications.append(notification)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.notifications.removeAll { $0.id == notification.id }
            }
        }
    }
    
    func showSuccess(_ message: String) {
        scheduleNotification(title: "Успешно", message: message, type: .success)
    }
    
    func showError(_ message: String) {
        scheduleNotification(title: "Ошибка", message: message, type: .error)
    }
    
    func showWarning(_ message: String) {
        scheduleNotification(title: "Внимание", message: message, type: .warning)
    }
    
    func showInfo(_ message: String) {
        scheduleNotification(title: "Информация", message: message, type: .info)
    }
}

struct AppNotification: Identifiable {
    let id: String
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
}

enum NotificationType {
    case success
    case error
    case warning
    case info
    
    var color: Color {
        switch self {
        case .success: return Color(red: 0.0, green: 0.4, blue: 0.8)
        case .error: return Color(red: 0.8, green: 0.2, blue: 0.0)
        case .warning: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .info: return Color(white: 0.5)
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }
}
