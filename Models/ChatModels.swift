import Foundation

// MARK: - Message Role
enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    let attachedFiles: [FileItem]
    let isStreaming: Bool
    var streamedContent: String

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        attachedFiles: [FileItem] = [],
        isStreaming: Bool = false,
        streamedContent: String = ""
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.attachedFiles = attachedFiles
        self.isStreaming = isStreaming
        self.streamedContent = streamedContent
    }

    var displayContent: String {
        if isStreaming {
            return streamedContent
        }
        return content
    }

    var isFromSwitch: Bool {
        role == .assistant
    }

    var isFromUser: Bool {
        role == .user
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - File Type
enum FileType: String, Codable, CaseIterable {
    case image
    case document
    case audio
    case video
    case archive
    case code
    case spreadsheet
    case presentation
    case other

    var iconName: String {
        switch self {
        case .image: return "photo.fill"
        case .document: return "doc.fill"
        case .audio: return "music.note"
        case .video: return "video.fill"
        case .archive: return "doc.zipper"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .spreadsheet: return "tablecells.fill"
        case .presentation: return "play.rectangle.fill"
        case .other: return "doc.fill"
        }
    }

    var emoji: String {
        switch self {
        case .image: return "🖼"
        case .document: return "📄"
        case .audio: return "🎵"
        case .video: return "🎬"
        case .archive: return "📦"
        case .code: return "💻"
        case .spreadsheet: return "📊"
        case .presentation: return "📽️"
        case .other: return "📎"
        }
    }

    var displayName: String {
        switch self {
        case .image: return "Изображение"
        case .document: return "Документ"
        case .audio: return "Аудио"
        case .video: return "Видео"
        case .archive: return "Архив"
        case .code: return "Код"
        case .spreadsheet: return "Таблица"
        case .presentation: return "Презентация"
        case .other: return "Файл"
        }
    }

    static func fromExtension(_ ext: String) -> FileType {
        let lower = ext.lowercased()
        switch lower {
        case "jpg", "jpeg", "png", "gif", "webp", "heic", "bmp", "tiff":
            return .image
        case "pdf", "doc", "docx", "txt", "rtf", "odt":
            return .document
        case "mp3", "wav", "aac", "m4a", "flac", "ogg":
            return .audio
        case "mp4", "mov", "avi", "mkv", "webm":
            return .video
        case "zip", "rar", "7z", "tar", "gz":
            return .archive
        case "swift", "py", "js", "ts", "java", "c", "cpp", "html", "css", "json", "xml":
            return .code
        case "xls", "xlsx", "csv", "numbers":
            return .spreadsheet
        case "ppt", "pptx", "key":
            return .presentation
        default:
            return .other
        }
    }
}

// MARK: - File Item
struct FileItem: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let type: FileType
    let size: Int64
    let url: URL?
    let thumbnailData: Data?
    var isAnimatingLiquidation: Bool
    let mimeType: String?
    let lastModified: Date?

    init(
        id: UUID = UUID(),
        name: String,
        type: FileType,
        size: Int64 = 0,
        url: URL? = nil,
        thumbnailData: Data? = nil,
        isAnimatingLiquidation: Bool = false,
        mimeType: String? = nil,
        lastModified: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.size = size
        self.url = url
        self.thumbnailData = thumbnailData
        self.isAnimatingLiquidation = isAnimatingLiquidation
        self.mimeType = mimeType
        self.lastModified = lastModified
    }

    var formattedSize: String {
        if size == 0 { return "" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var fileExtension: String {
        URL(fileURLWithPath: name).pathExtension.uppercased()
    }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Model Option
struct ModelOption: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String
    let subtext: String
    let isSelected: Bool
    let modelId: String
    let iconName: String
    let accentColor: String

    init(
        id: UUID = UUID(),
        name: String,
        subtext: String,
        isSelected: Bool = false,
        modelId: String = "",
        iconName: String = "bolt.fill",
        accentColor: String = "#4A90E2"
    ) {
        self.id = id
        self.name = name
        self.subtext = subtext
        self.isSelected = isSelected
        self.modelId = modelId
        self.iconName = iconName
        self.accentColor = accentColor
    }
}

// MARK: - Tool Item
struct ToolItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let iconName: String
    let badge: String?
    let description: String
    let category: ToolCategory
    let isNew: Bool

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        badge: String? = nil,
        description: String = "",
        category: ToolCategory = .general,
        isNew: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.badge = badge
        self.description = description
        self.category = category
        self.isNew = isNew
    }
}

enum ToolCategory: String, CaseIterable {
    case media = "Медиа"
    case productivity = "Продуктивность"
    case creativity = "Творчество"
    case research = "Исследования"
    case general = "Общее"
}

// MARK: - Input Field State
enum InputFieldState: Equatable {
    case collapsed
    case expanded
    case recording
}

// MARK: - Chat Session
struct ChatSession: Identifiable, Equatable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var model: ModelOption
    var isPinned: Bool
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String = "Новый чат",
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        model: ModelOption = ModelOption(name: "3 Flash", subtext: "Сбалансированный", modelId: "claude-sonnet-4-20250514"),
        isPinned: Bool = false,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.model = model
        self.isPinned = isPinned
        self.isArchived = isArchived
    }

    var previewText: String {
        messages.first { $0.role == .user }?.content ?? "Пустой чат"
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: updatedAt, relativeTo: Date())
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var username: String
    var selectedModelId: UUID
    var hapticEnabled: Bool
    var soundEnabled: Bool
    var autoScrollEnabled: Bool
    var streamingEnabled: Bool
    var reasoningLevel: ReasoningLevel

    init(
        username: String = "дима",
        selectedModelId: UUID = UUID(),
        hapticEnabled: Bool = true,
        soundEnabled: Bool = true,
        autoScrollEnabled: Bool = true,
        streamingEnabled: Bool = true,
        reasoningLevel: ReasoningLevel = .balanced
    ) {
        self.username = username
        self.selectedModelId = selectedModelId
        self.hapticEnabled = hapticEnabled
        self.soundEnabled = soundEnabled
        self.autoScrollEnabled = autoScrollEnabled
        self.streamingEnabled = streamingEnabled
        self.reasoningLevel = reasoningLevel
    }
}

enum ReasoningLevel: String, CaseIterable, Codable {
    case minimal = "Минимальный"
    case balanced = "Средний"
    case extensive = "Расширенный"

    var description: String {
        switch self {
        case .minimal: return "Быстрые ответы"
        case .balanced: return "Оптимальный баланс"
        case .extensive: return "Глубокий анализ"
        }
    }
}

// MARK: - API Request / Response
struct SwitchAPIRequest: Codable {
    let model: String
    let messages: [APIMessage]
    let stream: Bool
    let temperature: Double
    let maxTokens: Int

    struct APIMessage: Codable {
        let role: String
        let content: String
    }
}

struct SwitchAPIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage?

    struct Choice: Codable {
        let index: Int
        let message: Message
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }

    struct Message: Codable {
        let role: String
        let content: String
    }

    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int

        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

struct StreamChunk: Codable {
    let choices: [Choice]?

    struct Choice: Codable {
        let index: Int
        let delta: Delta
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index
            case delta
            case finishReason = "finish_reason"
        }
    }

    struct Delta: Codable {
        let content: String?
    }
}

// MARK: - Notification
struct AppNotification: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let iconName: String
    let timestamp: Date
    let type: NotificationType

    enum NotificationType {
        case success
        case error
        case info
        case warning
    }
}

// MARK: - App Tab
enum AppTab: String, CaseIterable {
    case chat = "Чат"
    case history = "История"
    case explore = "Обзор"
    case profile = "Профиль"

    var iconName: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right.fill"
        case .history: return "clock.fill"
        case .explore: return "sparkles"
        case .profile: return "person.fill"
        }
    }
}

// MARK: - Animation Constants
struct AnimationConstants {
    static let springFast = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let springMedium = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let springSlow = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let easeInOutFast = Animation.easeInOut(duration: 0.2)
    static let easeInOutMedium = Animation.easeInOut(duration: 0.3)
    static let easeInOutSlow = Animation.easeInOut(duration: 0.5)
    static let easeOut = Animation.easeOut(duration: 0.3)
    static let easeIn = Animation.easeIn(duration: 0.3)
    static let linear = Animation.linear(duration: 0.3)
}

// MARK: - Layout Constants
struct LayoutConstants {
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 20
    static let cornerRadiusXXLarge: CGFloat = 28

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32

    static let iconSizeSmall: CGFloat = 16
    static let iconSizeMedium: CGFloat = 20
    static let iconSizeLarge: CGFloat = 24
    static let iconSizeXLarge: CGFloat = 32

    static let glassBlurRadius: CGFloat = 20
    static let glassBorderWidth: CGFloat = 0.5
}
