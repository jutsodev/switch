import SwiftUI
import Combine

struct SwitchPremiumFeaturesView: View {
    @State private var selectedPremiumTab: PremiumTab = .ai
    @State private var isPremiumUser = false
    @State private var premiumDaysLeft = 30
    
    enum PremiumTab: String, CaseIterable {
        case ai = "Продвинутый AI"
        case collaboration = "Сотрудничество"
        case advanced = "Продвинутые опции"
        case analytics = "Аналитика"
        case plugins = "Плагины"
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
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Switch Premium")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            if isPremiumUser {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                                    Text("Активна - осталось \(premiumDaysLeft) дней")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                                }
                            } else {
                                Text("Откройте полный потенциал")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Text("$9.99")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                            
                            Text("/месяц")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
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
                    
                    Button(action: {
                        withAnimation {
                            isPremiumUser = true
                            premiumDaysLeft = 30
                        }
                    }) {
                        if isPremiumUser {
                            Text("Управлять подпиской")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.5, green: 1.0, blue: 0.8),
                                            Color(red: 0.2, green: 0.8, blue: 1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(10)
                        } else {
                            Text("Начать бесплатный пробный период")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.2, green: 0.8, blue: 1.0),
                                            Color(red: 0.1, green: 0.7, blue: 1.0)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PremiumTab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation {
                                    selectedPremiumTab = tab
                                }
                            }) {
                                Text(tab.rawValue)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(selectedPremiumTab == tab ? .white : .white.opacity(0.5))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedPremiumTab == tab ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.8, blue: 1.0),
                                                Color(red: 0.5, green: 1.0, blue: 0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(white: 0.15),
                                                Color(white: 0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedPremiumTab {
                        case .ai:
                            PremiumAIFeaturesView()
                        case .collaboration:
                            CollaborationFeaturesView()
                        case .advanced:
                            AdvancedOptionsView()
                        case .analytics:
                            AnalyticsView()
                        case .plugins:
                            PluginsView()
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

struct PremiumAIFeaturesView: View {
    var body: some View {
        VStack(spacing: 12) {
            PremiumFeatureCard(
                icon: "brain.head.profile",
                title: "Расширенное предсказание",
                description: "Улучшенные модели с предсказанием поведения пользователя",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "waveform.circle.fill",
                title: "Обработка потокового аудио",
                description: "Анализируйте аудио в реальном времени",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "video.fill",
                title: "Анализ видео",
                description: "Полный анализ видео с распознаванием сцен",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "sparkles",
                title: "Генерация контента",
                description: "Создавайте профессиональный контент автоматически",
                isPremium: true
            )
        }
    }
}

struct CollaborationFeaturesView: View {
    var body: some View {
        VStack(spacing: 12) {
            PremiumFeatureCard(
                icon: "person.2.fill",
                title: "Командная работа",
                description: "Пригласите до 10 пользователей для совместной работы",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "message.badge.circle.fill",
                title: "Комментарии и обсуждение",
                description: "Обсуждайте результаты с командой",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "checkmark.seal.fill",
                title: "Контроль версий",
                description: "Отслеживайте все изменения и восстанавливайте версии",
                isPremium: true
            )
        }
    }
}

struct AdvancedOptionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            PremiumFeatureCard(
                icon: "gear.circle.fill",
                title: "Расширенные параметры",
                description: "Полный контроль над параметрами AI модели",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "shield.fill",
                title: "Пользовательская безопасность",
                description: "Двухфакторная аутентификация и шифрование",
                isPremium: true
            )
            
            PremiumFeatureCard(
                icon: "doc.fill",
                title: "Экспорт в форматы",
                description: "Экспортируйте в PDF, Word, Excel и многое другое",
                isPremium: true
            )
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        VStack(spacing: 12) {
            PremiumAnalyticsCard(
                title: "Использование запросов",
                value: "245/500",
                percentage: 0.49
            )
            
            PremiumAnalyticsCard(
                title: "Токены обработаны",
                value: "12.5M/50M",
                percentage: 0.25
            )
            
            PremiumAnalyticsCard(
                title: "Активность",
                value: "156 запросов",
                percentage: 0.75
            )
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Статистика использования")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Сегодня")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("45 запросов")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Эта неделя")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("280 запросов")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Этот месяц")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("1200 запросов")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
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
        }
    }
}

struct PluginsView: View {
    @State private var installedPlugins: [PluginItem] = [
        PluginItem(name: "GitHub Integration", icon: "link.circle.fill", isInstalled: true),
        PluginItem(name: "Slack Integration", icon: "message.circle.fill", isInstalled: true),
        PluginItem(name: "Google Drive", icon: "folder.fill", isInstalled: false),
        PluginItem(name: "Notion Integration", icon: "square.and.pencil", isInstalled: false)
    ]
    
    struct PluginItem: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        var isInstalled: Bool
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach($installedPlugins) { $plugin in
                HStack(spacing: 12) {
                    Image(systemName: plugin.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
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
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plugin.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(plugin.isInstalled ? "Установлен" : "Доступен")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    GlassToggle(isOn: $plugin.isInstalled, label: "")
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
    }
}

struct PremiumFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let isPremium: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
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
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                    }
                }
                
                Text(description)
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

struct PremiumAnalyticsCard: View {
    let title: String
    let value: String
    let percentage: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
            }
            
            LiquidProgressBar(progress: percentage)
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
    SwitchPremiumFeaturesView()
}
