import SwiftUI
import Combine

class SwitchNotificationManager: NSObject, ObservableObject {
    @Published var notifications: [SwitchNotification] = []
    static let shared = SwitchNotificationManager()
    
    override init() {
        super.init()
        setupDefaultNotifications()
    }
    
    func setupDefaultNotifications() {
        notifications = [
            SwitchNotification(
                id: UUID(),
                title: "Добро пожаловать в Switch",
                message: "Ваш личный AI ассистент готов помочь",
                icon: "sparkles",
                timestamp: Date(),
                isRead: false,
                priority: .high
            ),
            SwitchNotification(
                id: UUID(),
                title: "Обновление Premium",
                message: "Подпишитесь на Premium и получайте неограниченные запросы",
                icon: "crown.fill",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false,
                priority: .medium
            )
        ]
    }
    
    func addNotification(_ notification: SwitchNotification) {
        notifications.insert(notification, at: 0)
    }
    
    func markAsRead(id: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
    }
}

struct SwitchNotification: Identifiable {
    let id: UUID
    let title: String
    let message: String
    let icon: String
    let timestamp: Date
    var isRead: Bool
    let priority: NotificationPriority
    
    enum NotificationPriority {
        case low
        case medium
        case high
    }
}

struct NotificationCenter: View {
    @StateObject private var notificationManager = SwitchNotificationManager.shared
    @State private var selectedNotification: SwitchNotification?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Уведомления")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if !notificationManager.notifications.isEmpty {
                        Button(action: {
                            withAnimation {
                                notificationManager.clearAllNotifications()
                            }
                        }) {
                            Text("Очистить")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                        }
                    }
                }
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.15),
                            Color(red: 0.08, green: 0.08, blue: 0.12)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                if notificationManager.notifications.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text("Нет уведомлений")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Все уведомления очищены")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(notificationManager.notifications) { notification in
                                NotificationItemView(
                                    notification: notification,
                                    onTap: { selectedNotification = notification },
                                    onClose: {
                                        withAnimation {
                                            notificationManager.notifications.removeAll { $0.id == notification.id }
                                        }
                                    },
                                    onMarkRead: {
                                        notificationManager.markAsRead(id: notification.id)
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
    }
}

struct NotificationItemView: View {
    let notification: SwitchNotification
    let onTap: () -> Void
    let onClose: () -> Void
    let onMarkRead: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Image(systemName: notification.icon)
                    .font(.system(size: 18))
                    .foregroundColor(getPriorityColor(notification.priority))
                    .frame(width: 40, height: 40)
                    .background(
                        GlassMorphicCard(
                            backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                            blurRadius: 10,
                            cornerRadius: 8
                        ) {
                            EmptyView()
                        }
                    )
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(notification.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.8, blue: 1.0))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Text(notification.message)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(formatTime(notification.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(spacing: 6) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 32, height: 32)
                        .background(
                            GlassMorphicCard(
                                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                                blurRadius: 10,
                                cornerRadius: 6
                            ) {
                                EmptyView()
                            }
                        )
                }
                
                Spacer()
            }
        }
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 15,
                cornerRadius: 12
            ) {
                EmptyView()
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                onMarkRead()
                onTap()
            }
        }
    }
    
    private func getPriorityColor(_ priority: SwitchNotification.NotificationPriority) -> Color {
        switch priority {
        case .low:
            return Color(red: 0.5, green: 1.0, blue: 0.8)
        case .medium:
            return Color(red: 0.2, green: 0.8, blue: 1.0)
        case .high:
            return Color(red: 1.0, green: 0.6, blue: 0.3)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
    }
}

class SwitchSearchEngine: NSObject, ObservableObject {
    @Published var searchResults: [SearchResult] = []
    @Published var recentSearches: [String] = []
    @Published var isSearching = false
    
    func search(query: String) {
        isSearching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let results = self.generateSearchResults(for: query)
            self.searchResults = results
            
            if !query.isEmpty {
                self.recentSearches.insert(query, at: 0)
                if self.recentSearches.count > 10 {
                    self.recentSearches.removeLast()
                }
            }
            
            self.isSearching = false
        }
    }
    
    private func generateSearchResults(for query: String) -> [SearchResult] {
        return [
            SearchResult(
                id: UUID(),
                title: "Чат: \(query)",
                category: "Чаты",
                icon: "bubble.right.fill",
                timestamp: Date()
            ),
            SearchResult(
                id: UUID(),
                title: "Функция: \(query)",
                category: "Функции",
                icon: "sparkles",
                timestamp: Date()
            ),
            SearchResult(
                id: UUID(),
                title: "Результат: \(query)",
                category: "Результаты",
                icon: "doc.text.fill",
                timestamp: Date()
            )
        ]
    }
}

struct SearchResult: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let icon: String
    let timestamp: Date
}

struct SwitchSearchView: View {
    @StateObject private var searchEngine = SwitchSearchEngine()
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    LiquidTextField(
                        placeholder: "Поиск чатов и функций...",
                        text: $searchText,
                        onEditingChanged: { isEditing in
                            isSearching = isEditing
                        }
                    )
                    .onChange(of: searchText) { newValue in
                        searchEngine.search(query: newValue)
                    }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(12)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                        blurRadius: 15,
                        cornerRadius: 10
                    ) {
                        EmptyView()
                    }
                )
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 12) {
                        if searchText.isEmpty {
                            if !searchEngine.recentSearches.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Недавние поиски")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                                        .padding(.horizontal, 16)
                                    
                                    HStack {
                                        Text("Нет недавних поисков")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.5))
                                            .padding(16)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        } else {
                            if searchEngine.isSearching {
                                HStack {
                                    ProgressView()
                                        .tint(Color(red: 0.2, green: 0.8, blue: 1.0))
                                    
                                    Text("Поиск...")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    Spacer()
                                }
                                .padding(16)
                            } else if searchEngine.searchResults.isEmpty {
                                VStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white.opacity(0.3))
                                    
                                    Text("Результатов не найдено")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(40)
                            } else {
                                ForEach(searchEngine.searchResults) { result in
                                    SearchResultItemView(result: result)
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SearchResultItemView: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: result.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                .frame(width: 36, height: 36)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                        blurRadius: 10,
                        cornerRadius: 8
                    ) {
                        EmptyView()
                    }
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(result.category)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 15,
                cornerRadius: 10
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    SwitchSearchView()
}
