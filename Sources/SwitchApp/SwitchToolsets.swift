import SwiftUI

// MARK: - Switch Toolsets
// This file contains a massive collection of specialized tools and agent configurations.

struct SwitchToolset {
    struct Agent: Identifiable, Hashable {
        let id: String
        let name: String
        let description: String
        let icon: String
        let color: Color
        let systemPrompt: String
        let capabilities: [String]
    }
    
    static let agents: [Agent] = [
        Agent(
            id: "architect",
            name: "Архитектор систем",
            description: "Проектирование сложных систем и баз данных",
            icon: "building.columns.fill",
            color: .blue,
            systemPrompt: "Ты — ведущий системный архитектор. Твоя задача — проектировать масштабируемые, отказоустойчивые системы.",
            capabilities: ["UML", "Database Design", "Cloud Architecture"]
        ),
        Agent(
            id: "debugger",
            name: "Мастер отладки",
            description: "Поиск и исправление самых сложных багов",
            icon: "ladybug.fill",
            color: .red,
            systemPrompt: "Ты — эксперт по отладке. Анализируй логи и код, находи коренные причины ошибок.",
            capabilities: ["Log Analysis", "Stack Trace", "Memory Leaks"]
        ),
        Agent(
            id: "copywriter",
            name: "Креативный копирайтер",
            description: "Тексты, которые продают и вдохновляют",
            icon: "pencil.and.outline",
            color: .orange,
            systemPrompt: "Ты — профессиональный копирайтер. Пиши захватывающие тексты в любом стиле.",
            capabilities: ["SEO", "Storytelling", "Editing"]
        ),
        Agent(
            id: "analyst",
            name: "Дата-аналитик",
            description: "Превращение данных в инсайты",
            icon: "chart.bar.xaxis",
            color: .green,
            systemPrompt: "Ты — опытный аналитик данных. Твоя цель — находить закономерности и визуализировать их.",
            capabilities: ["Statistics", "Python", "SQL"]
        ),
        Agent(
            id: "security",
            name: "Эксперт по ИБ",
            description: "Аудит безопасности и защита данных",
            icon: "shield.checkerboard",
            color: .purple,
            systemPrompt: "Ты — специалист по кибербезопасности. Проверяй код на уязвимости и давай рекомендации по защите.",
            capabilities: ["Penetration Testing", "Encryption", "Compliance"]
        ),
        Agent(
            id: "translator",
            name: "Полиглот",
            description: "Точный перевод с сохранением контекста",
            icon: "globe",
            color: .cyan,
            systemPrompt: "Ты — профессиональный переводчик. Переводи тексты, сохраняя нюансы смысла и культурный контекст.",
            capabilities: ["Localization", "Grammar", "Slang"]
        )
    ]
}

// MARK: - Tool UI Components
struct AgentGrid: View {
    let onSelect: (SwitchToolset.Agent) -> Void
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(SwitchToolset.agents) { agent in
                Button(action: { onSelect(agent) }) {
                    AgentCard(agent: agent)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct AgentCard: View {
    let agent: SwitchToolset.Agent
    
    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 12) {
                GlassIcon(systemName: agent.icon, color: agent.color, size: 44)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(agent.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(agent.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                HStack(spacing: 6) {
                    ForEach(agent.capabilities.prefix(2), id: \.self) { cap in
                        Text(cap)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(agent.color.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(agent.color)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Prompt Lab Logic
class PromptLab: ObservableObject {
    @Published var currentPrompt: String = ""
    @Published var suggestions: [String] = []
    
    func enhance() {
        // Logic to enhance prompt using AI
        suggestions = [
            "Добавь больше контекста о целевой аудитории",
            "Уточни желаемый тон и стиль ответа",
            "Попроси ИИ привести примеры"
        ]
    }
}

// MARK: - Analytics Dashboard
struct AnalyticsDashboard: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                StatCard(title: "Запросы", value: "1,284", icon: "message.fill", color: .blue)
                StatCard(title: "Токены", value: "842K", icon: "cpu.fill", color: .purple)
            }
            
            PremiumCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Активность за неделю")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Simple chart representation
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(0..<7) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(SwitchPalette.electricBlue.opacity(0.6))
                                .frame(width: 30, height: CGFloat.random(in: 40...100))
                        }
                    }
                    .frame(height: 100)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
                Text(value)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
