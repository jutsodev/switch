import Foundation
import SwiftUI

final class ChatViewModel: ObservableObject {

    // MARK: - Inputs

    @Published var draft: String = ""
    @Published var isComposing: Bool = false

    // MARK: - UI state

    @Published var isSending: Bool = false
    @Published var errorBanner: String?
    @Published var showSidebar: Bool = false
    @Published var showSettings: Bool = false
    @Published var showModelPicker: Bool = false
    @Published var showVoiceMode: Bool = false
    @Published var showReasoningSubmenu: Bool = false
    @Published var showToolsSheet: Bool = false

    // MARK: - Dependencies

    let store: ConversationStore
    let settings: SettingsStore
    private let api: APIClient

    init(store: ConversationStore, settings: SettingsStore, api: APIClient) {
        self.store = store
        self.settings = settings
        self.api = api
    }

    // MARK: - Derived

    var activeConversation: Conversation? { store.activeConversation }

    var hasMessages: Bool {
        (activeConversation?.messages.isEmpty ?? true) == false
    }

    var canSend: Bool {
        !isSending && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    func startNewConversation() {
        store.startNewConversation(model: settings.selectedModel)
        draft = ""
        errorBanner = nil
        showSidebar = false
        if settings.hapticsEnabled { Haptics.medium() }
    }

    func switchTo(_ id: UUID) {
        store.setActive(id)
        showSidebar = false
        if settings.hapticsEnabled { Haptics.tap() }
    }

    func selectModel(_ model: SwitchModel) {
        settings.selectModel(model)
        if let id = store.activeConversationID {
            store.updateModel(model.id, for: id)
        }
        showModelPicker = false
        if settings.hapticsEnabled { Haptics.tap() }
    }

    func send() {
        guard canSend else { return }
        guard let conversationID = store.activeConversationID else { return }

        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        draft = ""
        errorBanner = nil

        if settings.hapticsEnabled { Haptics.medium() }

        let userMessage = ChatMessage(role: .user, content: prompt)
        store.append(message: userMessage, to: conversationID)

        let placeholder = ChatMessage(role: .assistant, content: "", isStreaming: true)
        store.append(message: placeholder, to: conversationID)

        isSending = true

        let snapshot = store.conversation(with: conversationID)?.messages ?? []
        let history = snapshot.filter { !$0.content.isEmpty || $0.role == .user }
        let model = settings.selectedModel
        let systemPrompt = model.systemPrompt + settings.reasoningSuffix
        let apiKey = settings.effectiveAPIKey
        let baseURL = settings.effectiveBaseURL
        let streaming = settings.streamingEnabled

        Task { [weak self] in
            guard let self else { return }
            do {
                let finalText: String
                if streaming {
                    finalText = try await self.api.streamCompletion(
                        history: history.filter { $0.role != .assistant || !$0.isStreaming },
                        systemPrompt: systemPrompt,
                        temperature: model.temperature,
                        maxTokens: model.maxTokens,
                        apiKey: apiKey,
                        baseURL: baseURL
                    ) { [weak self] partial in
                        self?.store.update(
                            lastAssistantMessageContentIn: conversationID,
                            content: partial,
                            isStreaming: true
                        )
                    }
                } else {
                    finalText = try await self.api.completion(
                        history: history.filter { $0.role != .assistant || !$0.isStreaming },
                        systemPrompt: systemPrompt,
                        temperature: model.temperature,
                        maxTokens: model.maxTokens,
                        apiKey: apiKey,
                        baseURL: baseURL
                    )
                }
                await MainActor.run {
                    self.store.update(
                        lastAssistantMessageContentIn: conversationID,
                        content: finalText.isEmpty ? "_(пустой ответ)_" : finalText,
                        isStreaming: false
                    )
                    self.isSending = false
                    if self.settings.hapticsEnabled { Haptics.success() }
                }
            } catch {
                await MainActor.run {
                    let message: String
                    if let apiError = error as? APIError {
                        message = apiError.errorDescription ?? "Неизвестная ошибка"
                    } else {
                        message = error.localizedDescription
                    }
                    self.store.update(
                        lastAssistantMessageContentIn: conversationID,
                        content: "_Ошибка: \(message)_",
                        isStreaming: false
                    )
                    self.errorBanner = message
                    self.isSending = false
                    if self.settings.hapticsEnabled { Haptics.error() }
                }
            }
        }
    }

    func dismissError() {
        errorBanner = nil
    }
}
