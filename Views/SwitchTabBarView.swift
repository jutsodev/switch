import SwiftUI

struct SwitchTabBarView: View {
    @State private var selectedTab: SwitchTab = .chat
    @StateObject private var apiClient = SwitchAPIClient.shared
    
    enum SwitchTab {
        case chat
        case features
        case premium
        case profile
        case settings
    }
    
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
                Group {
                    switch selectedTab {
                    case .chat:
                        SwitchMainChatView()
                    case .features:
                        SwitchAdvancedFeaturesView()
                    case .premium:
                        SwitchPremiumFeaturesView()
                    case .profile:
                        SwitchProfileView()
                    case .settings:
                        SwitchSettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .background(Color(white: 0.15))
                
                HStack(spacing: 0) {
                    SwitchTabBarItem(
                        icon: "bubble.right.fill",
                        label: "Чаты",
                        isSelected: selectedTab == .chat,
                        action: { selectedTab = .chat }
                    )
                    
                    SwitchTabBarItem(
                        icon: "sparkles",
                        label: "Функции",
                        isSelected: selectedTab == .features,
                        action: { selectedTab = .features }
                    )
                    
                    SwitchTabBarItem(
                        icon: "crown.fill",
                        label: "Premium",
                        isSelected: selectedTab == .premium,
                        action: { selectedTab = .premium }
                    )
                    
                    SwitchTabBarItem(
                        icon: "person.fill",
                        label: "Профиль",
                        isSelected: selectedTab == .profile,
                        action: { selectedTab = .profile }
                    )
                    
                    SwitchTabBarItem(
                        icon: "gear.fill",
                        label: "Настройки",
                        isSelected: selectedTab == .settings,
                        action: { selectedTab = .settings }
                    )
                }
                .frame(height: 60)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.9),
                            Color(red: 0.05, green: 0.05, blue: 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
        .environmentObject(apiClient)
    }
}

struct SwitchTabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
            
            Text(label)
                .font(.system(size: 9, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(isSelected ? Color(red: 0.2, green: 0.8, blue: 1.0) : .white.opacity(0.5))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }
    }
}

struct SwitchProfileView: View {
    @State private var userName = "Пользователь Switch"
    @State private var userEmail = "user@switch.ai"
    @State private var userBio = "AI энтузиаст"
    
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
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.8, blue: 1.0),
                                            Color(red: 0.9, green: 0.3, blue: 0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Text(String(userName.prefix(1)))
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.08, green: 0.08, blue: 0.12))
                                        .frame(width: 36, height: 36)
                                )
                        }
                        
                        VStack(spacing: 4) {
                            Text(userName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(userEmail)
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            
                            Text(userBio)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(
                        GlassMorphicCard(
                            backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                            blurRadius: 25,
                            cornerRadius: 16
                        ) {
                            EmptyView()
                        }
                    )
                    .padding(16)
                    
                    VStack(spacing: 12) {
                        StatItemView(icon: "message.badge.fill", label: "Всего чатов", value: "127")
                        StatItemView(icon: "clock.fill", label: "Время использования", value: "456ч")
                        StatItemView(icon: "star.fill", label: "Рейтинг", value: "4.9/5")
                        StatItemView(icon: "lightning.fill", label: "Запросов", value: "2,543")
                    }
                    .padding(16)
                    
                    VStack(spacing: 12) {
                        Text("Достижения")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            AchievementBadge(icon: "🎯", title: "Первый чат")
                            AchievementBadge(icon: "🚀", title: "100 запросов")
                            AchievementBadge(icon: "⭐", title: "Прямолинейный")
                        }
                    }
                    .padding(16)
                    .background(
                        GlassMorphicCard(
                            backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                            blurRadius: 15,
                            cornerRadius: 12
                        ) {
                            EmptyView()
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct StatItemView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
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
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 12,
                cornerRadius: 10
            ) {
                EmptyView()
            }
        )
    }
}

struct AchievementBadge: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 28))
            
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 12,
                cornerRadius: 10
            ) {
                EmptyView()
            }
        )
    }
}

struct SwitchSettingsView: View {
    @State private var isDarkMode = true
    @State private var soundEnabled = true
    @State private var notificationsEnabled = true
    @State private var dataUsageOptimization = false
    @State private var selectedLanguage = "Русский"
    
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
            
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Внешний вид")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            .padding(.horizontal, 16)
                        
                        GlassToggle(isOn: $isDarkMode, label: "Темный режим")
                            .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Уведомления")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            .padding(.horizontal, 16)
                        
                        GlassToggle(isOn: $notificationsEnabled, label: "Включить уведомления")
                            .padding(.horizontal, 16)
                        
                        GlassToggle(isOn: $soundEnabled, label: "Звук")
                            .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Оптимизация")
                            .font(.system(size, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            .padding(.horizontal, 16)
                        
                        GlassToggle(isOn: $dataUsageOptimization, label: "Оптимизировать использование данных")
                            .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Язык")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            .padding(.horizontal, 16)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text(selectedLanguage)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            GlassMorphicCard(
                                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                                blurRadius: 12,
                                cornerRadius: 10
                            ) {
                                EmptyView()
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Информация")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            .padding(.horizontal, 16)
                        
                        SettingItemView(icon: "info.circle.fill", label: "О приложении", value: "v1.0.0")
                        SettingItemView(icon: "doc.text.fill", label: "Условия использования", value: "")
                        SettingItemView(icon: "lock.fill", label: "Политика приватности", value: "")
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }
        }
    }
}

struct SettingItemView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                .frame(width: 32, height: 32)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                        blurRadius: 10,
                        cornerRadius: 8
                    ) {
                        EmptyView()
                    }
                )
            
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 12,
                cornerRadius: 10
            ) {
                EmptyView()
            }
        )
    }
}

#Preview {
    SwitchTabBarView()
}
