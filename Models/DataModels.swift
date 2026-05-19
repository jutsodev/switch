import Foundation

struct GeminiModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let tier: ModelTier
    let releaseDate: Date
    let maxTokens: Int
    let costPer1MInputTokens: Double
    let costPer1MOutputTokens: Double
    
    enum ModelTier: String, Codable, CaseIterable {
        case flash = "Flash"
        case flashLite = "Flash Lite"
        case pro = "Pro"
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date
    var isEdited: Bool = false
    var reactions: [String: Int] = [:]
    var references: [String] = []
    
    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
}

struct ChatSession: Identifiable, Codable {
    let id: String
    let title: String
    var messages: [ChatMessage] = []
    let createdAt: Date
    var lastModified: Date
    let model: GeminiModel
    var isTemporary: Bool = false
    var attachedFiles: [AttachedFile] = []
    var pinned: Bool = false
    
    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        lastModified = Date()
    }
}

struct AttachedFile: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: FileType
    let size: Int
    let uploadedAt: Date
    var isProcessing: Bool = false
    
    enum FileType: String, Codable, CaseIterable {
        case image
        case document
        case text
        case audio
        case video
        case code
    }
}

struct ToolOption: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isNew: Bool
    let category: ToolCategory
    
    enum ToolCategory: String, Codable, CaseIterable {
        case media = "Media"
        case research = "Research"
        case productivity = "Productivity"
        case integration = "Integration"
    }
}

struct UIState {
    var isKeyboardVisible: Bool = false
    var inputFieldScale: CGFloat = 1.0
    var inputFieldOffset: CGFloat = 0
    var selectedModel: GeminiModel
    var isModelMenuOpen: Bool = false
    var isToolsMenuOpen: Bool = false
}

struct Theme {
    static let backgroundColorDark = Color(red: 0.09, green: 0.09, blue: 0.09)
    static let surfaceColor = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let primaryAccent = Color(red: 0.8, green: 0.2, blue: 0.0)
    static let secondaryAccent = Color(red: 0.0, green: 0.4, blue: 0.8)
    static let textPrimary = Color(white: 0.95)
    static let textSecondary = Color(white: 0.7)
    static let borderColor = Color(white: 0.2)
}

class DataStore: NSObject, ObservableObject {
    @Published var allModels: [GeminiModel] = []
    @Published var allTools: [ToolOption] = []
    @Published var recentChats: [ChatSession] = []
    @Published var currentChat: ChatSession?
    
    override init() {
        super.init()
        initializeDefaultData()
    }
    
    private func initializeDefaultData() {
        let flashModel = GeminiModel(
            id: "gemini-2.0-flash",
            name: "Gemini 2.0 Flash",
            description: "Fast, efficient model for quick responses",
            tier: .flash,
            releaseDate: Date(),
            maxTokens: 1000000,
            costPer1MInputTokens: 0.075,
            costPer1MOutputTokens: 0.3
        )
        
        let flashLiteModel = GeminiModel(
            id: "gemini-2.0-flash-lite",
            name: "Gemini 2.0 Flash Lite",
            description: "Lightweight model for basic tasks",
            tier: .flashLite,
            releaseDate: Date(),
            maxTokens: 100000,
            costPer1MInputTokens: 0.04,
            costPer1MOutputTokens: 0.15
        )
        
        let proModel = GeminiModel(
            id: "gemini-2.0-pro",
            name: "Gemini 2.0 Pro",
            description: "Advanced reasoning and complex tasks",
            tier: .pro,
            releaseDate: Date(),
            maxTokens: 2000000,
            costPer1MInputTokens: 0.15,
            costPer1MOutputTokens: 0.6
        )
        
        allModels = [flashLiteModel, flashModel, proModel]
        
        let tools: [ToolOption] = [
            ToolOption(id: "images", title: "Изображения", description: "Generate and analyze images", icon: "photo", isNew: false, category: .media),
            ToolOption(id: "music", title: "Музыка", description: "Create and explore music", icon: "music.quaver", isNew: true, category: .media),
            ToolOption(id: "canvas", title: "Canvas", description: "Design and prototype", icon: "square.and.pencil", isNew: false, category: .productivity),
            ToolOption(id: "research", title: "Deep Research", description: "In-depth analysis and exploration", icon: "magnifyingglass", isNew: false, category: .research),
            ToolOption(id: "learning", title: "Обучение", description: "Learn new concepts and skills", icon: "book.fill", isNew: false, category: .productivity)
        ]
        
        allTools = tools
    }
}

class FileRemovalService: NSObject, ObservableObject {
    @Published var activeRemovals: Set<String> = []
    @Published var removalQueue: [String] = []
    
    private var removalTimer: Timer?
    
    func queueFileForRemoval(_ fileId: String) {
        removalQueue.append(fileId)
        processRemovalQueue()
    }
    
    private func processRemovalQueue() {
        guard let nextFileId = removalQueue.first else { return }
        
        if activeRemovals.count < 1 {
            activeRemovals.insert(nextFileId)
            removalQueue.removeFirst()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.activeRemovals.remove(nextFileId)
                self.processRemovalQueue()
            }
        }
    }
}
