import SwiftUI
import Combine

class GeminiUIViewModel: NSObject, ObservableObject {
    @Published var uiState = UIState(selectedModel: GeminiModel(
        id: "gemini-2.0-flash",
        name: "Gemini 2.0 Flash",
        description: "Fast model",
        tier: .flash,
        releaseDate: Date(),
        maxTokens: 1000000,
        costPer1MInputTokens: 0.075,
        costPer1MOutputTokens: 0.3
    ))
    
    @Published var currentInputText: String = ""
    @Published var selectedFiles: [AttachedFile] = []
    @Published var isRecordingAudio: Bool = false
    @Published var displayedChatMessages: [ChatMessage] = []
    @Published var showLoadingIndicator: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let keyboardPublisher = KeyboardPublisher()
    
    override init() {
        super.init()
        setupKeyboardListeners()
    }
    
    private func setupKeyboardListeners() {
        keyboardPublisher.keyboardVisible
            .assign(to: \.uiState.isKeyboardVisible, on: self)
            .store(in: &cancellables)
    }
    
    func toggleModelMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            uiState.isModelMenuOpen.toggle()
        }
    }
    
    func toggleToolsMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            uiState.isToolsMenuOpen.toggle()
        }
    }
    
    func selectModel(_ model: GeminiModel) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            uiState.selectedModel = model
            uiState.isModelMenuOpen = false
        }
        triggerHapticFeedback(style: .light)
    }
    
    func attachFile(_ file: AttachedFile) {
        selectedFiles.append(file)
        triggerHapticFeedback(style: .medium)
    }
    
    func removeFile(_ fileId: String) {
        selectedFiles.removeAll { $0.id == fileId }
        triggerHapticFeedback(style: .light)
    }
    
    func sendMessage() {
        guard !currentInputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let message = ChatMessage(
            id: UUID().uuidString,
            role: .user,
            content: currentInputText,
            timestamp: Date()
        )
        
        displayedChatMessages.append(message)
        currentInputText = ""
        selectedFiles.removeAll()
        
        showLoadingIndicator = true
        triggerHapticFeedback(style: .medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responseMessage = ChatMessage(
                id: UUID().uuidString,
                role: .assistant,
                content: "This is a simulated response from Gemini AI.",
                timestamp: Date()
            )
            self.displayedChatMessages.append(responseMessage)
            self.showLoadingIndicator = false
        }
    }
    
    func startAudioRecording() {
        isRecordingAudio = true
        triggerHapticFeedback(style: .heavy)
    }
    
    func stopAudioRecording() {
        isRecordingAudio = false
        triggerHapticFeedback(style: .light)
    }
    
    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

class KeyboardPublisher: NSObject, ObservableObject {
    @Published var keyboardVisible = false
    
    override init() {
        super.init()
        setupKeyboardObservers()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIKeyboardWillShow.self,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIKeyboardWillHide.self,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow() {
        DispatchQueue.main.async {
            self.keyboardVisible = true
        }
    }
    
    @objc private func keyboardWillHide() {
        DispatchQueue.main.async {
            self.keyboardVisible = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
