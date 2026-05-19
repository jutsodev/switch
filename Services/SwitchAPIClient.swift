import SwiftUI
import Combine

class SwitchAPIClient: NSObject, ObservableObject {
    static let shared = SwitchAPIClient()
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var currentResponse: String? = nil
    @Published var conversationHistory: [ChatMessage] = []
    
    private let apiKey = "sk-82bceb8e214b56c34ca35838140024ae4340e36dcfb5afe4"
    private let baseURL = "https://api.ecomagent.in/v1"
    private let session = URLSession.shared
    private let model = "claude-sonnet-4-20250514"
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        var config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
    }
    
    func sendMessage(_ message: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            role: .user,
            content: message,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.conversationHistory.append(userMessage)
        }
        
        let messagesForAPI = conversationHistory.map { message -> [String: String] in
            [
                "role": message.role.rawValue,
                "content": message.content
            ]
        }
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messagesForAPI,
            "max_tokens": 2048,
            "temperature": 0.7
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            DispatchQueue.main.async {
                self.errorMessage = "Ошибка сериализации запроса"
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        session.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Нет данных в ответе"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        let assistantMessage = ChatMessage(
                            id: UUID().uuidString,
                            role: .assistant,
                            content: content,
                            timestamp: Date()
                        )
                        
                        self?.conversationHistory.append(assistantMessage)
                        self?.currentResponse = content
                    } else {
                        self?.errorMessage = "Ошибка парсинга ответа"
                    }
                } catch {
                    self?.errorMessage = "Ошибка декодирования: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func clearHistory() {
        conversationHistory.removeAll()
        currentResponse = nil
        errorMessage = nil
    }
}

struct SwitchAPIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Codable {
        let index: Int
        let message: Message
        let finish_reason: String
        
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
    
    struct Usage: Codable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode = true
    @Published var primaryColor = Color(red: 0.2, green: 0.8, blue: 1.0)
    @Published var secondaryColor = Color(red: 1.0, green: 0.2, blue: 0.8)
    @Published var accentColor = Color(red: 0.4, green: 0.9, blue: 0.7)
    
    func applyLiquidGlassTheme() {
        primaryColor = Color(red: 0.3, green: 0.85, blue: 1.0)
        secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.8)
        accentColor = Color(red: 0.5, green: 1.0, blue: 0.8)
    }
}

class StreamingResponseHandler: NSObject, ObservableObject {
    @Published var streamingText: String = ""
    @Published var isStreaming = false
    @Published var streamingProgress: Double = 0
    
    private var urlSession: URLSession?
    private var currentTask: URLSessionWebSocketTask?
    
    func startStreamingResponse(_ message: String, apiKey: String) {
        isStreaming = true
        streamingText = ""
        
        let requestBody: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "messages": [
                ["role": "user", "content": message]
            ],
            "stream": true,
            "max_tokens": 2048
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            isStreaming = false
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.ecomagent.in/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Streaming error: \(error)")
                self?.isStreaming = false
                return
            }
            
            guard let data = data else {
                self?.isStreaming = false
                return
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            let lines = responseString.split(separator: "\n").map(String.init)
            
            for line in lines {
                if line.starts(with: "data: ") {
                    let jsonString = String(line.dropFirst(6))
                    if jsonString == "[DONE]" {
                        self?.isStreaming = false
                        continue
                    }
                    
                    if let jsonData = jsonString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let delta = firstChoice["delta"] as? [String: Any],
                       let content = delta["content"] as? String {
                        
                        DispatchQueue.main.async {
                            self?.streamingText += content
                            self?.streamingProgress += 0.01
                        }
                    }
                }
            }
        }.resume()
    }
}
