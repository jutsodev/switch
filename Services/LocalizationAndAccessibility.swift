import SwiftUI

class LocalizationService: NSObject, ObservableObject {
    static let shared = LocalizationService()
    
    @Published var currentLanguage: Language = .russian
    
    enum Language: String, CaseIterable {
        case russian = "ru"
        case english = "en"
    }
    
    private let localizations: [Language: [String: String]] = [
        .russian: [
            "welcome_title": "Добро пожаловать в Gemini",
            "welcome_subtitle": "Ваш личный AI ассистент",
            "start_chat": "Начать чат",
            "new_chat": "Новый чат",
            "settings": "Настройки",
            "about": "О приложении",
            "feedback": "Отзыв",
            "logout": "Выход",
            "chat_input_placeholder": "Спросите Gemini",
            "error_network": "Ошибка сети",
            "error_unknown": "Неизвестная ошибка",
            "success": "Успешно",
            "loading": "Загрузка...",
            "empty_state": "Здесь ничего нет",
            "retry": "Повторить",
            "cancel": "Отмена",
            "delete": "Удалить",
            "edit": "Редактировать",
            "save": "Сохранить",
            "search": "Поиск",
            "model_selection": "Выбор модели",
            "flash_model": "Gemini Flash",
            "pro_model": "Gemini Pro",
            "temporary_chat": "Временный чат",
            "delete_chat": "Удалить чат?",
            "confirm_delete": "Это действие нельзя отменить",
            "messages_count": "%d сообщений",
            "created_at": "Создано",
            "last_modified": "Последнее изменение",
            "today": "Сегодня",
            "yesterday": "Вчера",
            "week": "На этой неделе",
            "month": "В этом месяце",
            "send": "Отправить",
            "copy": "Скопировать",
            "share": "Поделиться",
            "more": "Ещё",
            "language": "Язык",
            "theme": "Тема",
            "notifications": "Уведомления",
            "privacy": "Приватность",
            "terms": "Условия использования"
        ],
        .english: [
            "welcome_title": "Welcome to Gemini",
            "welcome_subtitle": "Your personal AI assistant",
            "start_chat": "Start Chat",
            "new_chat": "New Chat",
            "settings": "Settings",
            "about": "About",
            "feedback": "Feedback",
            "logout": "Logout",
            "chat_input_placeholder": "Ask Gemini",
            "error_network": "Network Error",
            "error_unknown": "Unknown Error",
            "success": "Success",
            "loading": "Loading...",
            "empty_state": "Nothing here",
            "retry": "Retry",
            "cancel": "Cancel",
            "delete": "Delete",
            "edit": "Edit",
            "save": "Save",
            "search": "Search",
            "model_selection": "Model Selection",
            "flash_model": "Gemini Flash",
            "pro_model": "Gemini Pro",
            "temporary_chat": "Temporary Chat",
            "delete_chat": "Delete Chat?",
            "confirm_delete": "This action cannot be undone",
            "messages_count": "%d messages",
            "created_at": "Created",
            "last_modified": "Last Modified",
            "today": "Today",
            "yesterday": "Yesterday",
            "week": "This Week",
            "month": "This Month",
            "send": "Send",
            "copy": "Copy",
            "share": "Share",
            "more": "More",
            "language": "Language",
            "theme": "Theme",
            "notifications": "Notifications",
            "privacy": "Privacy",
            "terms": "Terms of Service"
        ]
    ]
    
    func localizedString(for key: String, language: Language? = nil) -> String {
        let lang = language ?? currentLanguage
        return localizations[lang]?[key] ?? key
    }
    
    func localizedString(_ key: String) -> String {
        return localizedString(for: key)
    }
}

struct LocalizedText: View {
    let key: String
    let font: Font
    let color: Color
    
    @ObservedObject var localization = LocalizationService.shared
    
    init(_ key: String, font: Font = .body, color: Color = .white) {
        self.key = key
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text(localization.localizedString(for: key))
            .font(font)
            .foregroundColor(color)
    }
}

class AccessibilityService: NSObject, ObservableObject {
    static let shared = AccessibilityService()
    
    @Published var screenReaderEnabled = false
    @Published var boldTextEnabled = false
    @Published var reduceTransparencyEnabled = false
    @Published var reduceMotionEnabled = false
    @Published var largeTextEnabled = false
    
    override init() {
        super.init()
        detectAccessibilitySettings()
    }
    
    private func detectAccessibilitySettings() {
        screenReaderEnabled = UIAccessibility.isScreenReaderEnabled
        boldTextEnabled = UIAccessibility.isBoldTextEnabled
        reduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
        reduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        largeTextEnabled = UIAccessibility.isLargerTextEnabled
    }
    
    func announceForAccessibility(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

struct AccessibleButton: View {
    let label: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(label)
            }
        }
        .accessibilityLabel(label)
        .accessibilityHint("Нажмите чтобы выполнить действие")
    }
}

struct AccessibleImage: View {
    let systemName: String
    let label: String
    let color: Color
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(color)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isImage)
    }
}

struct AccessibleField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.5))
                }
                .foregroundColor(.white)
                .frame(height: 40)
                .padding(.horizontal, 12)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .accessibilityLabel(label)
                .accessibilityHint(placeholder)
        }
    }
}

class DarkModeService: NSObject, ObservableObject {
    @Published var isDarkMode = true
    @Published var useSystemSettings = true
    
    override init() {
        super.init()
        detectSystemDarkMode()
    }
    
    private func detectSystemDarkMode() {
        if #available(iOS 13.0, *) {
            let interfaceStyle = UIApplication.shared.windows.first?.overrideUserInterfaceStyle ?? .unspecified
            isDarkMode = interfaceStyle == .dark
        }
    }
}

struct ThemePreviewView: View {
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(theme.primaryColor)
                    .frame(width: 20, height: 20)
                
                Circle()
                    .fill(theme.secondaryColor)
                    .frame(width: 20, height: 20)
                
                Spacer()
            }
            
            Text(theme.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
    }
}

struct MultilanguageSelector: View {
    @State private var selectedLanguage: LocalizationService.Language = .russian
    @ObservedObject var localization = LocalizationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "language"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                ForEach(LocalizationService.Language.allCases, id: \.self) { language in
                    Button(action: {
                        withAnimation {
                            selectedLanguage = language
                            localization.currentLanguage = language
                        }
                    }) {
                        Text(language.rawValue.uppercased())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(selectedLanguage == language ? .white : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(selectedLanguage == language ? Color(red: 0.0, green: 0.4, blue: 0.8) : Color(white: 0.15))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(8)
    }
}

struct ContentSecurityView: View {
    @State private var sensitiveContentHidden = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                
                Text("Безопасность контента")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Toggle("Скрыть чувствительный контент", isOn: $sensitiveContentHidden)
                .tint(Color(red: 0.0, green: 0.4, blue: 0.8))
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(8)
    }
}

class RateLimitingService: NSObject {
    static let shared = RateLimitingService()
    
    private var requestTimestamps: [String: [Date]] = [:]
    private let maxRequestsPerMinute = 60
    
    func canMakeRequest(for endpoint: String) -> Bool {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        
        if var timestamps = requestTimestamps[endpoint] {
            timestamps = timestamps.filter { $0 > oneMinuteAgo }
            
            if timestamps.count >= maxRequestsPerMinute {
                return false
            }
            
            timestamps.append(now)
            requestTimestamps[endpoint] = timestamps
        } else {
            requestTimestamps[endpoint] = [now]
        }
        
        return true
    }
    
    func getRemainingRequests(for endpoint: String) -> Int {
        let now = Date()
        let oneMinuteAgo = now.addingTimeInterval(-60)
        
        if let timestamps = requestTimestamps[endpoint] {
            let validTimestamps = timestamps.filter { $0 > oneMinuteAgo }
            return max(0, maxRequestsPerMinute - validTimestamps.count)
        }
        
        return maxRequestsPerMinute
    }
}

struct ComplianceNoticeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                
                Text("Соответствие GDPR")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text("Мы соблюдаем все требования GDPR и защищаем вашу приватность. Ваши данные не передаются третьим лицам.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(3)
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
    }
}

struct AnalyticsOptInView: View {
    @State private var analyticsEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                
                Text("Аналитика")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Toggle("Помочь улучшить приложение", isOn: $analyticsEnabled)
                .tint(Color(red: 0.0, green: 0.4, blue: 0.8))
            
            Text("Анонимные данные об использовании помогают нам улучшать сервис")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(8)
    }
}

class PermissionService: NSObject, ObservableObject {
    @Published var cameraPermission: PermissionStatus = .notDetermined
    @Published var microphonePermission: PermissionStatus = .notDetermined
    @Published var photoLibraryPermission: PermissionStatus = .notDetermined
    
    enum PermissionStatus {
        case notDetermined
        case restricted
        case denied
        case granted
    }
    
    func requestCameraPermission() {
        
    }
    
    func requestMicrophonePermission() {
        
    }
    
    func requestPhotoLibraryPermission() {
        
    }
}

#Preview {
    MultilanguageSelector()
        .environmentObject(LocalizationService.shared)
}
