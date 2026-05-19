import Foundation
import Combine

@MainActor
final class SwitchAIClient: ObservableObject {
    @Published private(set) var conversation = SwitchConversation()
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var lastError: String?
    @Published var responseLatency: TimeInterval?

    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(session: URLSession = .shared) {
        self.session = session
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
        conversation.messages = [
            SwitchChatMessage(role: .assistant, content: "Привет. Я Switch — быстрый, аккуратный AI-клиент с Liquid Glass интерфейсом. Чем помочь?", state: .sent)
        ]
    }

    func reset(model: SwitchModel? = nil) {
        conversation = SwitchConversation(model: model ?? conversation.model)
        conversation.messages = [SwitchChatMessage(role: .assistant, content: "Новый чат готов. Выберите модель и напишите задачу.")]
        inputText = ""
        lastError = nil
    }

    func use(model: SwitchModel) {
        conversation.model = model
        conversation.updatedAt = Date()
    }

    func sendCurrentMessage() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading else { return }
        inputText = ""
        await send(trimmed)
    }

    func send(_ text: String) async {
        let userMessage = SwitchChatMessage(role: .user, content: text, state: .sent)
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()
        isLoading = true
        lastError = nil
        let start = Date()
        do {
            let response = try await complete(messages: conversation.messages, model: conversation.model)
            responseLatency = Date().timeIntervalSince(start)
            conversation.messages.append(SwitchChatMessage(role: .assistant, content: response, state: .sent))
            conversation.updatedAt = Date()
        } catch {
            lastError = error.localizedDescription
            conversation.messages.append(SwitchChatMessage(role: .assistant, content: "Не удалось получить ответ: \(error.localizedDescription)", state: .failed))
        }
        isLoading = false
    }

    private func complete(messages: [SwitchChatMessage], model: SwitchModel) async throws -> String {
        var request = URLRequest(url: SwitchRuntime.endpoint.appendingPathComponent("chat/completions"))
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SwitchRuntime.apiKey)", forHTTPHeaderField: "Authorization")
        let payload = SwitchChatRequest(
            model: model.id,
            messages: messages.suffix(24).map { SwitchChatRequest.Message(role: $0.role.rawValue, content: $0.content) },
            temperature: 0.72,
            maxTokens: 4096,
            stream: false
        )
        request.httpBody = try encoder.encode(payload)
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SwitchAPIError.invalidResponse }
        guard 200..<300 ~= http.statusCode else {
            let serverMessage = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw SwitchAPIError.server(status: http.statusCode, message: serverMessage)
        }
        let decoded = try decoder.decode(SwitchChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content, !content.isEmpty else { throw SwitchAPIError.emptyResponse }
        return content
    }
}

struct SwitchRuntime {
    static var endpoint: URL {
        if let value = Bundle.main.object(forInfoDictionaryKey: "SWITCH_API_BASE_URL") as? String, let url = URL(string: value) { return url }
        return URL(string: "https://api.ecomagent.in/v1")!
    }

    static var apiKey: String {
        if let value = Bundle.main.object(forInfoDictionaryKey: "SWITCH_API_KEY") as? String, !value.isEmpty, !value.contains("$(") { return value }
        if let value = ProcessInfo.processInfo.environment["SWITCH_API_KEY"], !value.isEmpty { return value }
        return "sk-82bceb8e214b56c34ca35838140024ae4340e36dcfb5afe4"
    }
}

struct SwitchChatRequest: Codable {
    struct Message: Codable { let role: String; let content: String }
    let model: String
    let messages: [Message]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool
}

struct SwitchChatResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable { let role: String?; let content: String }
        let index: Int?
        let message: Message
        let finishReason: String?
    }
    struct Usage: Codable { let promptTokens: Int?; let completionTokens: Int?; let totalTokens: Int? }
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [Choice]
    let usage: Usage?
}

enum SwitchAPIError: LocalizedError {
    case invalidResponse
    case emptyResponse
    case server(status: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Некорректный сетевой ответ."
        case .emptyResponse: return "Пустой ответ модели."
        case .server(let status, let message): return "Ошибка сервера \(status): \(message.prefix(260))"
        }
    }
}
