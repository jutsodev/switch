import Foundation
import SwiftUI

// MARK: - Models catalog

/// One of the LLM personas the user can pick from inside the app.
/// All personas resolve to the same upstream model (`claude-sonnet-4-20250514`)
/// but use different system prompts and `reasoning` hints.
struct SwitchModel: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let systemPrompt: String
    let temperature: Double
    let maxTokens: Int

    static let flashLite = SwitchModel(
        id: "switch-flash-lite",
        name: "Flash-Lite",
        subtitle: "Самые быстрые ответы",
        systemPrompt: "Ты — Switch Flash-Lite, краткий и быстрый ассистент. Отвечай коротко и по делу, без лишних слов.",
        temperature: 0.5,
        maxTokens: 1024
    )

    static let flash = SwitchModel(
        id: "switch-flash",
        name: "3 Flash",
        subtitle: "All-around help",
        systemPrompt: "Ты — Switch 3 Flash, универсальный помощник. Балансируй между скоростью и качеством, отвечай дружелюбно и понятно.",
        temperature: 0.7,
        maxTokens: 2048
    )

    static let pro = SwitchModel(
        id: "switch-pro",
        name: "3.1 Pro",
        subtitle: "Advanced math & code",
        systemPrompt: "Ты — Switch 3.1 Pro. Решаешь сложные задачи по математике, программированию и анализу. Думай пошагово, давай подробные обоснования.",
        temperature: 0.4,
        maxTokens: 4096
    )

    static let all: [SwitchModel] = [.flashLite, .flash, .pro]
}

/// Reasoning effort hint shown in the model picker submenu.
enum ReasoningLevel: String, CaseIterable, Codable, Identifiable {
    case minimal
    case balanced
    case extensive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .minimal:   return "Минимальный"
        case .balanced:  return "Средний"
        case .extensive: return "Расширенный"
        }
    }

    var subtitle: String {
        switch self {
        case .minimal:   return "Быстрые ответы"
        case .balanced:  return "Оптимальный баланс"
        case .extensive: return "Глубокий анализ"
        }
    }
}

// MARK: - Messages

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let role: MessageRole
    var content: String
    let createdAt: Date
    var isStreaming: Bool

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        createdAt: Date = Date(),
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.isStreaming = isStreaming
    }

    var isAssistant: Bool { role == .assistant }
    var isUser: Bool { role == .user }
}

// MARK: - Conversation

struct Conversation: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var modelId: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        title: String = "Новый чат",
        modelId: String = SwitchModel.flash.id,
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.modelId = modelId
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }

    var preview: String {
        messages.first(where: { $0.role == .user })?.content ?? "Пустой чат"
    }

    var humanRelativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }

    func model() -> SwitchModel {
        SwitchModel.all.first(where: { $0.id == modelId }) ?? .flash
    }
}

// MARK: - Tools shown in the "+" sheet

struct SwitchTool: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
    let isNew: Bool

    static let primaryTools: [SwitchTool] = [
        SwitchTool(id: "photo", title: "Фото", systemImage: "photo", isNew: false),
        SwitchTool(id: "camera", title: "Камера", systemImage: "camera", isNew: false),
        SwitchTool(id: "files", title: "Файлы", systemImage: "folder", isNew: false),
        SwitchTool(id: "drive", title: "Диск", systemImage: "externaldrive", isNew: false),
        SwitchTool(id: "notes", title: "Блокноты", systemImage: "note.text", isNew: false)
    ]

    static let advancedTools: [SwitchTool] = [
        SwitchTool(id: "images", title: "Изображения", systemImage: "photo.artframe", isNew: false),
        SwitchTool(id: "music", title: "Музыка", systemImage: "music.note", isNew: true),
        SwitchTool(id: "canvas", title: "Canvas", systemImage: "paintbrush.pointed", isNew: false),
        SwitchTool(id: "research", title: "Deep Research", systemImage: "magnifyingglass", isNew: false),
        SwitchTool(id: "study", title: "Обучение", systemImage: "book", isNew: false)
    ]
}
