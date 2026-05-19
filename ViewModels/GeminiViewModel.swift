import Foundation
import Combine

@MainActor
final class GeminiViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var attachedFiles: [FileItem] = []
    @Published var selectedModel: ModelOption
    @Published var inputText: String = ""
    @Published var inputState: InputFieldState = .collapsed
    @Published var isModelMenuVisible: Bool = false
    @Published var isToolsMenuVisible: Bool = false
    @Published var isLoading: Bool = false
    @Published var liquidationQueue: [FileItem] = []

    let availableModels: [ModelOption] = [
        ModelOption(name: "Flash-Lite", subtext: "Быстрый и лёгкий", isSelected: false),
        ModelOption(name: "3 Flash", subtext: "Сбалансированный", isSelected: true),
        ModelOption(name: "3.1 Pro", subtext: "Расширенные возможности", isSelected: false)
    ]

    let horizontalTools: [ToolItem] = [
        ToolItem(name: "Фото", iconName: "photo"),
        ToolItem(name: "Камера", iconName: "camera"),
        ToolItem(name: "Файлы", iconName: "folder"),
        ToolItem(name: "Диск", iconName: "externaldrive"),
        ToolItem(name: "Блокноты", iconName: "note.text")
    ]

    let verticalTools: [ToolItem] = [
        ToolItem(name: "Изображения", iconName: "photo.artframe"),
        ToolItem(name: "Музыка", iconName: "music.note", badge: "Новинка"),
        ToolItem(name: "Canvas", iconName: "paintbrush"),
        ToolItem(name: "Deep Research", iconName: "magnifyingglass"),
        ToolItem(name: "Обучение", iconName: "book")
    ]

    var hasAttachedFiles: Bool {
        !attachedFiles.isEmpty
    }

    init() {
        self.selectedModel = availableModels[1]
    }

    func toggleModelMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isModelMenuVisible.toggle()
        }
        triggerHaptic(.medium)
    }

    func toggleToolsMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isToolsMenuVisible.toggle()
        }
        triggerHaptic(.light)
    }

    func selectModel(_ model: ModelOption) {
        guard let index = availableModels.firstIndex(where: { $0.id == model.id }) else { return }
        var updated = availableModels
        for i in 0..<updated.count {
            updated[i] = ModelOption(
                id: updated[i].id,
                name: updated[i].name,
                subtext: updated[i].subtext,
                isSelected: i == index
            )
        }
        selectedModel = updated[index]
        isModelMenuVisible = false
        triggerHaptic(.light)
    }

    func expandInput() {
        withAnimation(.easeInOut(duration: 0.3)) {
            inputState = .expanded
        }
    }

    func collapseInput() {
        withAnimation(.easeInOut(duration: 0.3)) {
            inputState = .collapsed
            inputText = ""
        }
    }

    func attachFile(_ file: FileItem) {
        attachedFiles.append(file)
        expandInput()
        triggerHaptic(.light)
    }

    func removeFile(_ file: FileItem) {
        liquidationQueue.append(file)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.attachedFiles.removeAll { $0.id == file.id }
            self?.liquidationQueue.removeAll { $0.id == file.id }
        }
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !attachedFiles.isEmpty else { return }

        let content = inputText.isEmpty ? "[Вложения]" : inputText
        let message = ChatMessage(
            role: .user,
            content: content,
            attachedFiles: attachedFiles
        )
        messages.append(message)

        inputText = ""
        collapseInput()
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            let response = ChatMessage(
                role: .gemini,
                content: "Это тестовый ответ от Gemini. Интеграция с API будет добавлена позже.",
                attachedFiles: []
            )
            self.messages.append(response)
            self.isLoading = false
            self.attachedFiles.removeAll()
        }

        triggerHaptic(.medium)
    }

    func clearChat() {
        messages.removeAll()
        attachedFiles.removeAll()
        liquidationQueue.removeAll()
        collapseInput()
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}