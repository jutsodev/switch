import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: TabItem = .chat
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .chat:
                        ContentView()
                    case .explore:
                        ExploreView()
                    case .history:
                        ChatSessionManager()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .background(Color(white: 0.15))
                
                HStack(spacing: 0) {
                    TabBarItem(
                        icon: "bubble.right",
                        label: "Чаты",
                        isSelected: selectedTab == .chat,
                        action: { selectedTab = .chat }
                    )
                    
                    TabBarItem(
                        icon: "compass",
                        label: "Исследование",
                        isSelected: selectedTab == .explore,
                        action: { selectedTab = .explore }
                    )
                    
                    TabBarItem(
                        icon: "clock.fill",
                        label: "История",
                        isSelected: selectedTab == .history,
                        action: { selectedTab = .history }
                    )
                    
                    TabBarItem(
                        icon: "person.fill",
                        label: "Профиль",
                        isSelected: selectedTab == .profile,
                        action: { selectedTab = .profile }
                    )
                }
                .frame(height: 60)
                .background(Color(white: 0.09))
            }
        }
    }
}

enum TabItem {
    case chat
    case explore
    case history
    case profile
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
            
            Text(label)
                .font(.system(size: 10, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(isSelected ? Color(red: 0.0, green: 0.4, blue: 0.8) : .white.opacity(0.5))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }
    }
}

struct ExploreView: View {
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Исследование")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ExploreCardView(
                            category: "Программирование",
                            icon: "laptopcomputer",
                            description: "Изучите основы разработки"
                        )
                        
                        ExploreCardView(
                            category: "Наука",
                            icon: "microscope",
                            description: "Откройте для себя научные концепции"
                        )
                        
                        ExploreCardView(
                            category: "Искусство",
                            icon: "paintbrush.pointed.fill",
                            description: "Исследуйте творческие идеи"
                        )
                        
                        ExploreCardView(
                            category: "История",
                            icon: "book.fill",
                            description: "Узнайте об исторических событиях"
                        )
                        
                        ExploreCardView(
                            category: "Технологии",
                            icon: "figure.walk.motion",
                            description: "Следите за последними технологиями"
                        )
                    }
                    .padding(12)
                }
            }
        }
    }
}

struct ExploreCardView: View {
    let category: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(category)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
            }
        }
        .padding(16)
        .background(Color(white: 0.12))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {}
    }
}

struct ProfileView: View {
    @State private var userName = "Дима"
    @State private var userEmail = "dima@example.com"
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Профиль")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                    }
                }
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            ZStack(alignment: .bottomTrailing) {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.8, green: 0.2, blue: 0.0),
                                            Color(red: 0.2, green: 0.4, blue: 0.9)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                
                                Text(userName.prefix(1))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                                    .background(
                                        Circle()
                                            .fill(Color("backgroundColor"))
                                            .frame(width: 28, height: 28)
                                    )
                                    .offset(x: 8, y: 8)
                            }
                            
                            VStack(spacing: 4) {
                                Text(userName)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(userEmail)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(Color(white: 0.09))
                        .cornerRadius(12)
                        
                        VStack(spacing: 8) {
                            ProfileStatRow(
                                icon: "bubble.right",
                                label: "Всего чатов",
                                value: "47"
                            )
                            
                            ProfileStatRow(
                                icon: "message.badge",
                                label: "Всего сообщений",
                                value: "342"
                            )
                            
                            ProfileStatRow(
                                icon: "calendar",
                                label: "Присоединился",
                                value: "15 мая 2024"
                            )
                        }
                        .padding(12)
                        .background(Color(white: 0.09))
                        .cornerRadius(12)
                        
                        VStack(spacing: 8) {
                            ProfileMenuRow(
                                icon: "bell.fill",
                                label: "Уведомления",
                                value: "Включены"
                            )
                            
                            ProfileMenuRow(
                                icon: "lock.fill",
                                label: "Приватность",
                                value: "Защищено"
                            )
                            
                            ProfileMenuRow(
                                icon: "heart.fill",
                                label: "Избранные чаты",
                                value: "8"
                            )
                        }
                        .padding(12)
                        .background(Color(white: 0.09))
                        .cornerRadius(12)
                        
                        Button(action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                                
                                Text("Выход")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(white: 0.12))
                            .cornerRadius(8)
                        }
                    }
                    .padding(12)
                }
            }
        }
        .alert("Подтвердить выход?", isPresented: $showLogoutAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Выход", role: .destructive) { }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct ProfileStatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color(white: 0.12))
        .cornerRadius(6)
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 30)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(10)
        .background(Color(white: 0.12))
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onTapGesture {}
    }
}

#Preview {
    TabBarView()
        .environmentObject(AppCoordinator())
}
