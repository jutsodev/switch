import SwiftUI

@main
struct SwitchProfessionalApp: App {
    @StateObject private var appState = SwitchAppState()
    @StateObject private var apiClient = SwitchAIClient()
    @StateObject private var coreEngine = SwitchCoreEngine.shared

    var body: some Scene {
        WindowGroup {
            SwitchRootViewV2()
                .environmentObject(appState)
                .environmentObject(apiClient)
                .environmentObject(coreEngine)
                .preferredColorScheme(.dark)
        }
    }
}

@MainActor
final class SwitchAppState: ObservableObject {
    @Published var selectedModel: SwitchModel = .sonnet
    @Published var activeScreen: SwitchScreen = .chat
    @Published var isSidebarVisible = false
    @Published var isComposerExpanded = false
    @Published var showSettings = false
    @Published var focusMode = false
    @Published var ambientMotion = true
    @Published var liquidIntensity: Double = 0.82
    @Published var accent: SwitchAccent = .electricBlue
    @Published var notification: SwitchNotification?

    let quickPrompts: [QuickPrompt] = [
        QuickPrompt(title: "Улучшить код", subtitle: "Рефакторинг, баги, архитектура", icon: "chevron.left.forwardslash.chevron.right"),
        QuickPrompt(title: "Написать текст", subtitle: "Письма, посты, документы", icon: "text.quote"),
        QuickPrompt(title: "Deep Research", subtitle: "Структурированный анализ", icon: "magnifyingglass.circle"),
        QuickPrompt(title: "Создать план", subtitle: "Roadmap, задачи, дедлайны", icon: "calendar.badge.clock")
    ]

    func present(_ message: String, style: SwitchNotification.Style = .success) {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
            notification = SwitchNotification(message: message, style: style)
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            withAnimation(.easeInOut(duration: 0.24)) { notification = nil }
        }
    }
}

enum SwitchScreen: String, CaseIterable, Identifiable {
    case chat = "Switch"
    case tools = "Tools"
    case history = "History"
    case settings = "Settings"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .chat: return "sparkles"
        case .tools: return "square.grid.2x2.fill"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape.fill"
        }
    }
}

enum SwitchAccent: String, CaseIterable, Identifiable {
    case electricBlue = "Electric Blue"
    case glacier = "Glacier"
    case graphite = "Graphite"
    var id: String { rawValue }
    var primary: Color {
        switch self {
        case .electricBlue: return Color(red: 0.08, green: 0.42, blue: 1.0)
        case .glacier: return Color(red: 0.44, green: 0.76, blue: 1.0)
        case .graphite: return Color(red: 0.62, green: 0.68, blue: 0.78)
        }
    }
    var secondary: Color {
        switch self {
        case .electricBlue: return Color(red: 0.1, green: 0.75, blue: 1.0)
        case .glacier: return Color.white.opacity(0.92)
        case .graphite: return Color(red: 0.22, green: 0.25, blue: 0.31)
        }
    }
}

struct QuickPrompt: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
}

struct SwitchNotification: Identifiable, Equatable {
    enum Style { case success, warning, error }
    let id = UUID()
    let message: String
    let style: Style
}
