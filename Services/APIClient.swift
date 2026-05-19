import Foundation

/// Thin client for the OpenAI-compatible endpoint at api.ecomagent.in.
/// The real upstream is Claude Sonnet 4.
actor APIClient {

    // MARK: Configuration

    /// Bundled fallback key. Users can override in Settings.
    /// IMPORTANT: This key is visible in any IPA that ships with this build.
    /// Rotate when going public.
    static let defaultAPIKey =
        "sk-82bceb8e214b56c34ca35838140024ae4340e36dcfb5afe4"

    static let defaultBaseURL = URL(string: "https://api.ecomagent.in/v1")!

    /// Upstream model name the proxy expects.
    static let upstreamModel = "claude-sonnet-4-20250514"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Public API

    /// Streams an assistant reply token-by-token. The callback is invoked on the
    /// main actor with the accumulated text so far.
    func streamCompletion(
        history: [ChatMessage],
        systemPrompt: String,
        temperature: Double,
        maxTokens: Int,
        apiKey: String,
        baseURL: URL,
        onToken: @escaping (String) -> Void
    ) async throws -> String {
        let request = try buildRequest(
            history: history,
            systemPrompt: systemPrompt,
            temperature: temperature,
            maxTokens: maxTokens,
            stream: true,
            apiKey: apiKey,
            baseURL: baseURL
        )

        let (bytes, response) = try await session.bytes(for: request)
        try Self.validate(response: response)

        var accumulated = ""
        for try await line in bytes.lines {
            guard line.hasPrefix("data:") else { continue }
            let payload = line
                .dropFirst("data:".count)
                .trimmingCharacters(in: .whitespaces)
            if payload == "[DONE]" { break }
            guard let data = payload.data(using: .utf8) else { continue }
            do {
                let chunk = try decoder.decode(StreamChunk.self, from: data)
                if let delta = chunk.choices.first?.delta.content, !delta.isEmpty {
                    accumulated += delta
                    let snapshot = accumulated
                    await MainActor.run { onToken(snapshot) }
                }
            } catch {
                // Skip unparseable SSE frames (e.g. keepalive comments).
                continue
            }
        }
        return accumulated
    }

    /// Non-streaming completion. Used when streaming is disabled.
    func completion(
        history: [ChatMessage],
        systemPrompt: String,
        temperature: Double,
        maxTokens: Int,
        apiKey: String,
        baseURL: URL
    ) async throws -> String {
        let request = try buildRequest(
            history: history,
            systemPrompt: systemPrompt,
            temperature: temperature,
            maxTokens: maxTokens,
            stream: false,
            apiKey: apiKey,
            baseURL: baseURL
        )

        let (data, response) = try await session.data(for: request)
        try Self.validate(response: response)
        let decoded = try decoder.decode(CompletionResponse.self, from: data)
        return decoded.choices.first?.message.content ?? ""
    }

    // MARK: - Request shape

    private func buildRequest(
        history: [ChatMessage],
        systemPrompt: String,
        temperature: Double,
        maxTokens: Int,
        stream: Bool,
        apiKey: String,
        baseURL: URL
    ) throws -> URLRequest {
        var messages: [WireMessage] = []
        if !systemPrompt.isEmpty {
            messages.append(WireMessage(role: "system", content: systemPrompt))
        }
        for m in history {
            messages.append(WireMessage(role: m.role.rawValue, content: m.content))
        }

        let body = CompletionRequest(
            model: Self.upstreamModel,
            messages: messages,
            stream: stream,
            temperature: temperature,
            maxTokens: maxTokens
        )

        var request = URLRequest(url: baseURL.appendingPathComponent("chat/completions"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(body)
        return request
    }

    private static func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.transport("Не HTTP-ответ")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(status: http.statusCode)
        }
    }
}

// MARK: - Wire types

enum APIError: LocalizedError {
    case transport(String)
    case http(status: Int)
    case decoding

    var errorDescription: String? {
        switch self {
        case .transport(let msg): return "Сеть: \(msg)"
        case .http(let status):
            switch status {
            case 401: return "Ошибка авторизации (401). Проверьте API-ключ."
            case 403: return "Доступ запрещён (403)."
            case 404: return "Эндпоинт не найден (404)."
            case 429: return "Лимит запросов (429). Попробуйте позже."
            case 500..<600: return "Сервер недоступен (\(status))."
            default: return "HTTP \(status)"
            }
        case .decoding: return "Не удалось разобрать ответ."
        }
    }
}

private struct WireMessage: Codable {
    let role: String
    let content: String
}

private struct CompletionRequest: Codable {
    let model: String
    let messages: [WireMessage]
    let stream: Bool
    let temperature: Double
    let maxTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, messages, stream, temperature
        case maxTokens = "max_tokens"
    }
}

private struct CompletionResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable { let role: String; let content: String }
        let index: Int
        let message: Message
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }
    let id: String?
    let model: String?
    let choices: [Choice]
}

private struct StreamChunk: Decodable {
    struct Choice: Decodable {
        struct Delta: Decodable { let content: String? }
        let index: Int
        let delta: Delta
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case index, delta
            case finishReason = "finish_reason"
        }
    }
    let choices: [Choice]
}
