import SwiftUI

struct ChatSessionManager: View {
    @StateObject private var dataStore = DataStore()
    @State private var selectedSession: ChatSession? = nil
    @State private var showNewChat = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Text("Чаты")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { showNewChat = true }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(white: 0.15))
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    .background(Color("backgroundColor"))
                    
                    if dataStore.recentChats.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 48))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("Нет чатов")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Начните новый чат для начала")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color("backgroundColor"))
                    } else {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(dataStore.recentChats) { session in
                                    ChatSessionRowView(session: session)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedSession = session
                                        }
                                }
                            }
                            .padding(12)
                        }
                    }
                }
            }
        }
    }
}

struct ChatSessionRowView: View {
    let session: ChatSession
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if session.pinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                    }
                    
                    Text(session.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                
                Text(session.model.name)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                if session.isTemporary {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        
                        Text("Временный чат")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDate(session.lastModified))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("\(session.messages.count) сообщений")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Menu {
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
                
                Button {
                } label: {
                    Label("Дублировать", systemImage: "doc.on.doc")
                }
                
                Button {
                } label: {
                    Label(session.pinned ? "Открепить" : "Закрепить", 
                          systemImage: session.pinned ? "pin.slash" : "pin")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .alert("Удалить чат?", isPresented: $showDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) { }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startOfDate = calendar.startOfDay(for: date)
        
        if startOfDate == today {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if startOfDate == calendar.date(byAdding: .day, value: -1, to: today) {
            return "Вчера"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct SearchChatsView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("", text: $searchText)
                    .placeholder(when: searchText.isEmpty) {
                        Text("Поиск чатов")
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
        }
        .padding(12)
    }
}

struct TemporaryChatNotificationView: View {
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                
                Text("Временный чат")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showDetails.toggle() }) {
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            if showDetails {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Этот чат:")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                        
                        Text("Не появляется в списке недавних")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                        
                        Text("Не используется для улучшения ИИ")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                        
                        Text("Хранится 72 часа для безопасности")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .padding(12)
    }
}

#Preview {
    ChatSessionManager()
}
