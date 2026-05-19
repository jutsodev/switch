import Foundation
import SwiftUI

struct SwitchModel: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let tagline: String
    let maxTokens: Int
    let icon: String
    let tier: Tier

    enum Tier: String, Codable, CaseIterable { case fast = "Fast", balanced = "Balanced", pro = "Pro" }

    static let sonnet = SwitchModel(id: "claude-sonnet-4-20250514", displayName: "Switch Sonnet 4", tagline: "Профессиональный баланс скорости и качества", maxTokens: 200_000, icon: "bolt.circle.fill", tier: .balanced)
    static let haiku = SwitchModel(id: "claude-3-5-haiku-20241022", displayName: "Switch Flash", tagline: "Быстрые ответы и лёгкие задачи", maxTokens: 120_000, icon: "hare.fill", tier: .fast)
    static let opus = SwitchModel(id: "claude-opus-4-20250514", displayName: "Switch Pro", tagline: "Сложные рассуждения и большой контекст", maxTokens: 200_000, icon: "brain.head.profile", tier: .pro)
    static let all: [SwitchModel] = [.haiku, .sonnet, .opus]
}

struct SwitchChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable { case system, user, assistant }
    let id: UUID
    var role: Role
    var content: String
    var createdAt: Date
    var state: DeliveryState
    var attachments: [SwitchAttachment]

    enum DeliveryState: String, Codable { case sending, sent, streaming, failed }

    init(id: UUID = UUID(), role: Role, content: String, createdAt: Date = Date(), state: DeliveryState = .sent, attachments: [SwitchAttachment] = []) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.state = state
        self.attachments = attachments
    }

    var isUser: Bool { role == .user }
    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

struct SwitchAttachment: Identifiable, Codable, Equatable, Hashable {
    enum Kind: String, Codable { case image, document, audio, video, code, other }
    let id: UUID
    var name: String
    var kind: Kind
    var byteCount: Int
    var localURL: URL?

    init(id: UUID = UUID(), name: String, kind: Kind, byteCount: Int = 0, localURL: URL? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.byteCount = byteCount
        self.localURL = localURL
    }

    var icon: String {
        switch kind {
        case .image: return "photo.fill"
        case .document: return "doc.text.fill"
        case .audio: return "waveform"
        case .video: return "video.fill"
        case .code: return "curlybraces"
        case .other: return "paperclip"
        }
    }
}

struct SwitchConversation: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var messages: [SwitchChatMessage]
    var model: SwitchModel
    var createdAt: Date
    var updatedAt: Date

    init(id: UUID = UUID(), title: String = "Новый чат", messages: [SwitchChatMessage] = [], model: SwitchModel = .sonnet, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.model = model
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct SwitchTool: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let prompt: String

    static let catalog: [SwitchTool] = [
        SwitchTool(title: "Код-ревью", subtitle: "Найти баги и улучшения", icon: "checkmark.seal.fill", color: .blue, prompt: "Проведи профессиональное code review."),
        SwitchTool(title: "Архитектор", subtitle: "Схемы и решения", icon: "building.columns.fill", color: .cyan, prompt: "Спроектируй архитектуру решения."),
        SwitchTool(title: "Writer", subtitle: "Тексты и документы", icon: "pencil.and.outline", color: .white, prompt: "Напиши качественный текст."),
        SwitchTool(title: "Research", subtitle: "Глубокий анализ", icon: "scope", color: .indigo, prompt: "Сделай глубокое исследование темы."),
        SwitchTool(title: "Planner", subtitle: "План задач", icon: "list.bullet.clipboard.fill", color: .gray, prompt: "Составь пошаговый план."),
        SwitchTool(title: "Translator", subtitle: "Перевод и стиль", icon: "globe.europe.africa.fill", color: .mint, prompt: "Переведи и улучши стиль."),
        SwitchTool(title: "Prompt Lab", subtitle: "Усилить запрос", icon: "wand.and.stars", color: .purple, prompt: "Улучши следующий prompt."),
        SwitchTool(title: "Debug", subtitle: "Логи и ошибки", icon: "ladybug.fill", color: .red, prompt: "Помоги отладить ошибку.")
    ]
}
