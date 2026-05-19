import Foundation
import SwiftUI

/// Type-safe UserDefaults wrapper for the small set of user preferences.
final class SettingsStore: ObservableObject {

    private enum Key {
        static let username = "switch.username"
        static let modelId = "switch.modelId"
        static let reasoning = "switch.reasoning"
        static let streaming = "switch.streaming"
        static let haptics = "switch.haptics"
        static let apiKey = "switch.apiKey"
        static let baseURL = "switch.baseURL"
        static let liquidIntensity = "switch.liquid.intensity"
    }

    private let defaults: UserDefaults

    @Published var username: String {
        didSet { defaults.set(username, forKey: Key.username) }
    }

    @Published var selectedModelID: String {
        didSet { defaults.set(selectedModelID, forKey: Key.modelId) }
    }

    @Published var reasoning: ReasoningLevel {
        didSet { defaults.set(reasoning.rawValue, forKey: Key.reasoning) }
    }

    @Published var streamingEnabled: Bool {
        didSet { defaults.set(streamingEnabled, forKey: Key.streaming) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Key.haptics) }
    }

    /// Override for the bundled key. Empty string means "use bundled default".
    @Published var apiKeyOverride: String {
        didSet { defaults.set(apiKeyOverride, forKey: Key.apiKey) }
    }

    @Published var baseURLOverride: String {
        didSet { defaults.set(baseURLOverride, forKey: Key.baseURL) }
    }

    @Published var liquidIntensity: Double {
        didSet { defaults.set(liquidIntensity, forKey: Key.liquidIntensity) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.username = defaults.string(forKey: Key.username) ?? "дима"
        self.selectedModelID = defaults.string(forKey: Key.modelId) ?? SwitchModel.flash.id
        self.reasoning = ReasoningLevel(rawValue: defaults.string(forKey: Key.reasoning) ?? "")
            ?? .balanced
        self.streamingEnabled = (defaults.object(forKey: Key.streaming) as? Bool) ?? true
        self.hapticsEnabled = (defaults.object(forKey: Key.haptics) as? Bool) ?? true
        self.apiKeyOverride = defaults.string(forKey: Key.apiKey) ?? ""
        self.baseURLOverride = defaults.string(forKey: Key.baseURL) ?? ""
        self.liquidIntensity = (defaults.object(forKey: Key.liquidIntensity) as? Double) ?? 0.85
    }

    // MARK: - Derived

    var effectiveAPIKey: String {
        let trimmed = apiKeyOverride.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? APIClient.defaultAPIKey : trimmed
    }

    var effectiveBaseURL: URL {
        let trimmed = baseURLOverride.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), !trimmed.isEmpty {
            return url
        }
        return APIClient.defaultBaseURL
    }

    var selectedModel: SwitchModel {
        SwitchModel.all.first(where: { $0.id == selectedModelID }) ?? .flash
    }

    func selectModel(_ model: SwitchModel) {
        selectedModelID = model.id
    }

    /// Reasoning-flavoured system prompt suffix.
    var reasoningSuffix: String {
        switch reasoning {
        case .minimal:
            return "\n\nОтвечай как можно короче, без лишних рассуждений."
        case .balanced:
            return ""
        case .extensive:
            return "\n\nДумай шаг за шагом и подробно обосновывай выводы."
        }
    }
}
