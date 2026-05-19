import SwiftUI

struct NotificationCenterView: View {
    @StateObject private var notificationService = NotificationService.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            if !notificationService.notifications.isEmpty {
                VStack(spacing: 12) {
                    ForEach(notificationService.notifications) { notification in
                        NotificationBannerView(notification: notification)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                .padding(12)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: notificationService.notifications)
            }
        }
    }
}

struct NotificationBannerView: View {
    let notification: AppNotification
    @State private var isShowing = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(notification.type.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(notification.message)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .onAppear {
            isShowing = true
        }
    }
}

struct FileManagerView: View {
    @State private var selectedFiles: [AttachedFile] = []
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var showDocumentPicker = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Файлы")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(16)
                
                VStack(spacing: 12) {
                    FileManagerActionButton(
                        icon: "camera.fill",
                        title: "Камера",
                        action: { showCamera = true }
                    )
                    
                    FileManagerActionButton(
                        icon: "photo.fill",
                        title: "Фото и видео",
                        action: { showPhotoLibrary = true }
                    )
                    
                    FileManagerActionButton(
                        icon: "doc.fill",
                        title: "Документы",
                        action: { showDocumentPicker = true }
                    )
                    
                    FileManagerActionButton(
                        icon: "folder.fill",
                        title: "iCloud Drive",
                        action: {}
                    )
                    
                    FileManagerActionButton(
                        icon: "note.text",
                        title: "Блокноты",
                        action: {}
                    )
                }
                .padding(12)
                
                Spacer()
            }
        }
    }
}

struct FileManagerActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 50, height: 50)
                .background(Color(white: 0.12))
                .cornerRadius(12)
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

struct QuickActionsView: View {
    let onNewChat: () -> Void
    let onSettings: () -> Void
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                icon: "square.and.pencil",
                label: "Новый чат",
                action: onNewChat
            )
            
            QuickActionButton(
                icon: "magnifyingglass",
                label: "Поиск",
                action: onSearch
            )
            
            QuickActionButton(
                icon: "gear",
                label: "Настройки",
                action: onSettings
            )
            
            Spacer()
        }
        .padding(12)
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(white: 0.15))
                    .cornerRadius(8)
            }
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: [ChatMessage] = []
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("", text: $searchText)
                        .placeholder(when: searchText.isEmpty) {
                            Text("Поиск сообщений")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .frame(height: 40)
                .padding(.horizontal, 12)
                .background(Color(white: 0.15))
                .cornerRadius(8)
                .padding(12)
                
                if searchText.isEmpty {
                    VStack(spacing: 12) {
                        Text("Поиск по запросам")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 8) {
                            ForEach(["AI", "Python", "Swift", "WebDev"], id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(white: 0.15))
                                    .cornerRadius(6)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        searchText = tag
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(0..<5, id: \.self) { _ in
                                SearchResultRowView()
                            }
                        }
                        .padding(12)
                    }
                }
            }
        }
    }
}

struct SearchResultRowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "text.quote")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                
                Text("Что такое машинное обучение?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text("Машинное обучение - это область искусственного интеллекта, которая позволяет компьютерам...")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text("Gemini Flash")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                Text("2 дня назад")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {}
    }
}

#Preview {
    SearchView()
}
