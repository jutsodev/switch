import Foundation
import Combine

/// Persists all conversations as a single JSON file inside the app's Documents directory.
/// Small enough to never warrant Core Data — keeps the app debuggable.
final class ConversationStore: ObservableObject {

    @Published private(set) var conversations: [Conversation] = []
    @Published var activeConversationID: UUID?

    private let url: URL
    private let queue = DispatchQueue(label: "ConversationStore.io", qos: .utility)

    init(fileName: String = "conversations.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        self.url = docs.appendingPathComponent(fileName)
        load()
        if conversations.isEmpty {
            let new = Conversation()
            conversations = [new]
            activeConversationID = new.id
            save()
        } else {
            activeConversationID = conversations.first?.id
        }
    }

    // MARK: - Read access

    var activeConversation: Conversation? {
        guard let id = activeConversationID else { return conversations.first }
        return conversations.first(where: { $0.id == id })
    }

    func conversation(with id: UUID) -> Conversation? {
        conversations.first(where: { $0.id == id })
    }

    // MARK: - Mutations

    @discardableResult
    func startNewConversation(model: SwitchModel = .flash) -> Conversation {
        let c = Conversation(modelId: model.id)
        conversations.insert(c, at: 0)
        activeConversationID = c.id
        save()
        return c
    }

    func setActive(_ id: UUID) {
        activeConversationID = id
    }

    func append(message: ChatMessage, to id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].messages.append(message)
        conversations[index].updatedAt = Date()
        if conversations[index].title == "Новый чат", message.role == .user {
            let trimmed = message.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .prefix(60)
            conversations[index].title = trimmed.isEmpty ? "Новый чат" : String(trimmed)
        }
        save()
    }

    func update(lastAssistantMessageContentIn id: UUID, content: String, isStreaming: Bool) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        guard let lastIdx = conversations[index].messages.indices.last,
              conversations[index].messages[lastIdx].role == .assistant
        else { return }
        conversations[index].messages[lastIdx].content = content
        conversations[index].messages[lastIdx].isStreaming = isStreaming
        conversations[index].updatedAt = Date()
        save()
    }

    func togglePinned(_ id: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].isPinned.toggle()
        save()
    }

    func delete(_ id: UUID) {
        conversations.removeAll(where: { $0.id == id })
        if activeConversationID == id {
            activeConversationID = conversations.first?.id
        }
        save()
    }

    func deleteAll() {
        conversations.removeAll()
        let c = Conversation()
        conversations = [c]
        activeConversationID = c.id
        save()
    }

    func updateModel(_ modelID: String, for conversationID: UUID) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationID }) else { return }
        conversations[index].modelId = modelID
        save()
    }

    // MARK: - Disk I/O

    private func load() {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let list = try decoder.decode([Conversation].self, from: data)
            self.conversations = list.sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned { return lhs.isPinned && !rhs.isPinned }
                return lhs.updatedAt > rhs.updatedAt
            }
        } catch {
            // Corrupt or schema-changed: reset rather than crash.
            self.conversations = []
        }
    }

    private func save() {
        let snapshot = conversations
        let target = url
        queue.async {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(snapshot)
                try data.write(to: target, options: .atomic)
            } catch {
                // Best-effort persistence; user-visible state is still consistent.
            }
        }
    }
}
