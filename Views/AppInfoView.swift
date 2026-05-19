import SwiftUI

struct AppInfoView: View {
    @State private var selectedSection: InfoSection = .overview
    
    enum InfoSection {
        case overview
        case features
        case changelog
        case credits
        case help
    }
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("О приложении")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(16)
                
                HStack(spacing: 8) {
                    ForEach(InfoSection.allCases, id: \.self) { section in
                        Button(action: { selectedSection = section }) {
                            Text(section.displayName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(selectedSection == section ? .white : .white.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedSection == section ? Color(white: 0.15) : Color.clear)
                                .cornerRadius(6)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch selectedSection {
                        case .overview:
                            AppOverviewSection()
                        case .features:
                            AppFeaturesSection()
                        case .changelog:
                            ChangelogSection()
                        case .credits:
                            CreditsSection()
                        case .help:
                            HelpSection()
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

extension AppInfoView.InfoSection {
    static var allCases: [AppInfoView.InfoSection] = [.overview, .features, .changelog, .credits, .help]
    
    var displayName: String {
        switch self {
        case .overview: return "Обзор"
        case .features: return "Функции"
        case .changelog: return "История"
        case .credits: return "Авторы"
        case .help: return "Помощь"
        }
    }
}

struct AppOverviewSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                    
                    Text("Gemini Assistant")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    Text("Версия")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("1.0.0")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    Text("Build")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("2024.05.19")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .padding(12)
            .background(Color(white: 0.09))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Описание")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Gemini Assistant - это современное приложение для общения с искусственным интеллектом Google Gemini. Приложение позволяет вам взаимодействовать с различными моделями AI для решения задач, получения информации и творческого взаимодействия.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
            }
            .padding(12)
            .background(Color(white: 0.09))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Статистика")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    StatisticCard(icon: "bubble.right", label: "Чатов", value: "47")
                    StatisticCard(icon: "message", label: "Сообщений", value: "342")
                    StatisticCard(icon: "calendar", label: "Дней использования", value: "15")
                }
            }
            .padding(12)
            .background(Color(white: 0.09))
            .cornerRadius(8)
        }
    }
}

struct StatisticCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color(white: 0.12))
        .cornerRadius(6)
    }
}

struct AppFeaturesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FeatureItemView(
                icon: "sparkles",
                title: "Множественные модели AI",
                description: "Используйте Gemini Flash, Flash Lite и Pro для различных задач"
            )
            
            FeatureItemView(
                icon: "camera.fill",
                title: "Анализ изображений",
                description: "Загружайте фото и получайте детальный анализ"
            )
            
            FeatureItemView(
                icon: "waveform",
                title: "Голосовое взаимодействие",
                description: "Диктуйте сообщения и слушайте ответы"
            )
            
            FeatureItemView(
                icon: "doc.fill",
                title: "Работа с документами",
                description: "Загружайте файлы и работайте с текстом"
            )
            
            FeatureItemView(
                icon: "clock.fill",
                title: "Временные чаты",
                description: "Приватные чаты, которые удаляются через 72 часа"
            )
            
            FeatureItemView(
                icon: "pin.fill",
                title: "Закрепление чатов",
                description: "Сохраняйте важные разговоры в доступе"
            )
        }
    }
}

struct FeatureItemView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 30, alignment: .center)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(8)
    }
}

struct ChangelogSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ChangelogItemView(
                version: "1.0.0",
                date: "19 мая 2024",
                changes: [
                    "Выпуск первой версии приложения",
                    "Интеграция с Gemini API",
                    "Поддержка множественных моделей",
                    "Система шифрования сообщений"
                ]
            )
            
            ChangelogItemView(
                version: "0.9.0 (Beta)",
                date: "10 мая 2024",
                changes: [
                    "Начало бета-тестирования",
                    "Функция временных чатов",
                    "Анализ изображений",
                    "Голосовое взаимодействие"
                ]
            )
            
            ChangelogItemView(
                version: "0.8.0 (Alpha)",
                date: "1 мая 2024",
                changes: [
                    "Базовая функциональность приложения",
                    "Интерфейс пользователя",
                    "Основные чаты"
                ]
            )
        }
    }
}

struct ChangelogItemView: View {
    let version: String
    let date: String
    let changes: [String]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(version)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                Divider()
                    .background(Color(white: 0.2))
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(changes, id: \.self) { change in
                        HStack(spacing: 8) {
                            Text("•")
                                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                            
                            Text(change)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(8)
    }
}

struct CreditsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Разработчики")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                CreditItemView(name: "Gemini AI Team", role: "Основные разработчики")
                CreditItemView(name: "Design Team", role: "Дизайн интерфейса")
                CreditItemView(name: "QA Team", role: "Тестирование качества")
            }
            .padding(12)
            .background(Color(white: 0.09))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Технологии")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                HStack {
                    TechBadgeView(name: "SwiftUI")
                    TechBadgeView(name: "Combine")
                    TechBadgeView(name: "AVFoundation")
                }
                
                HStack {
                    TechBadgeView(name: "CoreML")
                    TechBadgeView(name: "Vision")
                    TechBadgeView(name: "SiriKit")
                }
            }
            .padding(12)
            .background(Color(white: 0.09))
            .cornerRadius(8)
        }
    }
}

struct CreditItemView: View {
    let name: String
    let role: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(role)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

struct TechBadgeView: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(white: 0.15))
            .cornerRadius(6)
    }
}

struct HelpSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FAQ(question: "Как начать новый чат?", answer: "Нажмите кнопку 'Новый чат' в главном меню или слайд-меню приложения. Вы сможете выбрать модель AI и начать разговор.")
            
            FAQ(question: "Какие модели доступны?", answer: "Доступны три основные модели: Flash (быстрая и универсальная), Flash Lite (легкая для базовых задач) и Pro (мощная для сложных задач).")
            
            FAQ(question: "Как загрузить файлы?", answer: "В поле ввода нажмите кнопку '+' для открытия меню инструментов. Там вы найдете опции для загрузки изображений, документов и других файлов.")
            
            FAQ(question: "Что такое временные чаты?", answer: "Временные чаты - это приватные разговоры, которые не сохраняются в истории и удаляются через 72 часа. Они не используются для обучения ИИ.")
            
            FAQ(question: "Как удалить чат?", answer: "Откройте меню чата (иконка трех точек) и выберите опцию 'Удалить'. Это действие нельзя отменить.")
        }
    }
}

struct FAQ: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(question)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                Divider()
                    .background(Color(white: 0.2))
                
                Text(answer)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(1.5)
            }
        }
        .padding(12)
        .background(Color(white: 0.09))
        .cornerRadius(8)
    }
}

#Preview {
    AppInfoView()
}
