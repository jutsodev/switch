import SwiftUI

class APIClient: NSObject, ObservableObject {
    static let shared = APIClient()
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let session = URLSession.shared
    private let baseURL = "https://api.example.com"
    
    func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        }
        
        if let parameters = parameters, method != .get {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.serializationError))
                return
            }
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func sendMessage(
        message: String,
        modelId: String,
        completion: @escaping (Result<String, APIError>) -> Void
    ) {
        let parameters: [String: Any] = [
            "message": message,
            "model_id": modelId
        ]
        
        makeRequest(
            endpoint: "/messages",
            method: .post,
            parameters: parameters
        ) { (result: Result<APIResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.content))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case noData
    case decodingError
    case serializationError
    case unauthorized
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .noData:
            return "Нет данных в ответе"
        case .decodingError:
            return "Ошибка декодирования данных"
        case .serializationError:
            return "Ошибка сериализации данных"
        case .unauthorized:
            return "Требуется авторизация"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        }
    }
}

struct APIResponse: Codable {
    let content: String
    let timestamp: Date?
    let usage: TokenUsage?
    
    enum CodingKeys: String, CodingKey {
        case content
        case timestamp
        case usage
    }
}

struct TokenUsage: Codable {
    let inputTokens: Int
    let outputTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case totalTokens = "total_tokens"
    }
}

class OfflineModeService: NSObject, ObservableObject {
    @Published var isOfflineMode = false
    @Published var cachedResponses: [String: String] = [:]
    
    func getOfflineResponse(for message: String) -> String {
        let offlineResponses = [
            "привет": "Привет! Я работаю в режиме офлайн. Мои возможности ограничены, но я все еще могу помочь с некоторыми задачами.",
            "спасибо": "Пожалуйста! Рад помочь.",
            "как дела": "Спасибо за внимание! Я работаю хорошо.",
            "помощь": "Я могу помочь с информацией, ответить на вопросы и вести беседу, но в режиме офлайн некоторые функции недоступны."
        ]
        
        let lowercaseMessage = message.lowercased()
        
        for (key, value) in offlineResponses {
            if lowercaseMessage.contains(key) {
                return value
            }
        }
        
        return "Извините, я не могу обработать ваш запрос в режиме офлайн. Пожалуйста, проверьте подключение к интернету."
    }
}

class RequestRateLimiter: NSObject {
    private var requestTimestamps: [String: [Date]] = [:]
    private let requestsPerMinute: Int
    private let lockQueue = DispatchQueue(label: "rate_limiter_lock")
    
    init(requestsPerMinute: Int = 60) {
        self.requestsPerMinute = requestsPerMinute
    }
    
    func canMakeRequest(for endpoint: String) -> Bool {
        var canMakeRequest = false
        
        lockQueue.sync {
            let now = Date()
            let oneMinuteAgo = now.addingTimeInterval(-60)
            
            if var timestamps = requestTimestamps[endpoint] {
                timestamps = timestamps.filter { $0 > oneMinuteAgo }
                
                if timestamps.count < requestsPerMinute {
                    timestamps.append(now)
                    requestTimestamps[endpoint] = timestamps
                    canMakeRequest = true
                }
            } else {
                requestTimestamps[endpoint] = [now]
                canMakeRequest = true
            }
        }
        
        return canMakeRequest
    }
    
    func reset() {
        lockQueue.async {
            self.requestTimestamps.removeAll()
        }
    }
}

class ResponseCache: NSObject {
    private let cache = NSCache<NSString, CachedResponse>()
    private let ttl: TimeInterval = 3600
    
    func cache(_ response: String, forKey key: String) {
        let cachedResponse = CachedResponse(response: response, timestamp: Date())
        cache.setObject(cachedResponse, forKey: key as NSString)
    }
    
    func getCachedResponse(forKey key: String) -> String? {
        guard let cachedResponse = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        if Date().timeIntervalSince(cachedResponse.timestamp) > ttl {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return cachedResponse.response
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

class CachedResponse: NSObject {
    let response: String
    let timestamp: Date
    
    init(response: String, timestamp: Date) {
        self.response = response
        self.timestamp = timestamp
    }
}

class ErrorHandler: NSObject, ObservableObject {
    @Published var currentError: AppError? = nil
    @Published var errorHistory: [AppError] = []
    
    static let shared = ErrorHandler()
    
    func handle(error: Error, context: String = "") {
        let appError = AppError(
            id: UUID().uuidString,
            message: error.localizedDescription,
            context: context,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.currentError = appError
            self.errorHistory.append(appError)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if self.currentError?.id == appError.id {
                    self.currentError = nil
                }
            }
        }
    }
    
    func clearError() {
        currentError = nil
    }
    
    func clearHistory() {
        errorHistory.removeAll()
    }
}

struct AppError: Identifiable {
    let id: String
    let message: String
    let context: String
    let timestamp: Date
}

class RequestInterceptor: NSObject {
    static let shared = RequestInterceptor()
    
    private var interceptors: [(URLRequest) -> URLRequest] = []
    private var responseInterceptors: [(URLResponse) -> URLResponse] = []
    
    func addRequestInterceptor(_ interceptor: @escaping (URLRequest) -> URLRequest) {
        interceptors.append(interceptor)
    }
    
    func addResponseInterceptor(_ interceptor: @escaping (URLResponse) -> URLResponse) {
        responseInterceptors.append(interceptor)
    }
    
    func processRequest(_ request: URLRequest) -> URLRequest {
        var processedRequest = request
        
        for interceptor in interceptors {
            processedRequest = interceptor(processedRequest)
        }
        
        return processedRequest
    }
    
    func processResponse(_ response: URLResponse) -> URLResponse {
        var processedResponse = response
        
        for interceptor in responseInterceptors {
            processedResponse = interceptor(processedResponse)
        }
        
        return processedResponse
    }
}
