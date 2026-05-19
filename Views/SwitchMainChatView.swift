import SwiftUI

struct SwitchMainChatView: View {
    @StateObject private var apiClient = SwitchAPIClient.shared
    @StateObject private var streamingHandler = StreamingResponseHandler()
    @State private var inputText = ""
    @State private var selectedModel = "claude-sonnet-4-20250514"
    @State private var showModelSelector = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SwitchHeaderBar(
                    showModelSelector: $showModelSelector,
                    showSettings: $showSettings
                )
                
                if apiClient.conversationHistory.isEmpty {
                    SwitchWelcomeView()
                } else {
                    ChatHistoryView(messages: apiClient.conversationHistory)
                }
                
                Spacer()
                
                SwitchInputArea(
                    inputText: $inputText,
                    isLoading: apiClient.isLoading,
                    onSend: {
                        apiClient.sendMessage(inputText)
                        inputText = ""
                    }
                )
            }
            
            if showModelSelector {
                ModelSelectorOverlay(
                    selectedModel: $selectedModel,
                    isShowing: $showModelSelector
                )
            }
            
            if showSettings {
                SwitchSettingsOverlay(isShowing: $showSettings)
            }
            
            if let error = apiClient.errorMessage {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                        
                        Text("Ошибка")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            apiClient.errorMessage = nil
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Text(error)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(12)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.3, green: 0.1, blue: 0.1),
                        blurRadius: 20,
                        cornerRadius: 12
                    ) {
                        EmptyView()
                    }
                )
                .padding(16)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

struct SwitchHeaderBar: View {
    @Binding var showModelSelector: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Switch AI")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Claude Sonnet 4")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
            }
            
            Spacer()
            
            Button(action: { showModelSelector = true }) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                    .frame(width: 44, height: 44)
                    .background(
                        GlassMorphicCard(
                            backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                            blurRadius: 10,
                            cornerRadius: 10
                        ) {
                            EmptyView()
                        }
                    )
            }
            
            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.8))
                    .frame(width: 44, height: 44)
                    .background(
                        GlassMorphicCard(
                            backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                            blurRadius: 10,
                            cornerRadius: 10
                        ) {
                            EmptyView()
                        }
                    )
            }
        }
        .padding(16)
    }
}

struct SwitchWelcomeView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                    .shadow(color: Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.5), radius: 20)
                
                Text("Switch AI")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Ваш интеллектуальный помощник")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                SwitchFeatureCard(
                    icon: "bolt.fill",
                    title: "Быстрые ответы",
                    description: "Получайте мгновенные ответы на любые вопросы"
                )
                
                SwitchFeatureCard(
                    icon: "brain.head.profile",
                    title: "Умные решения",
                    description: "Решайте сложные задачи с помощью AI"
                )
                
                SwitchFeatureCard(
                    icon: "shield.fill",
                    title: "Приватно и безопасно",
                    description: "Ваши данные защищены с помощью шифрования"
                )
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
    }
}

struct SwitchFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                .frame(width: 40, height: 40)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                        blurRadius: 10,
                        cornerRadius: 8
                    ) {
                        EmptyView()
                    }
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 15,
                cornerRadius: 12
            ) {
                EmptyView()
            }
        )
    }
}

struct ChatHistoryView: View {
    let messages: [ChatMessage]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        SwitchMessageBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(16)
            }
            .onAppear {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
            .onChange(of: messages) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct SwitchMessageBubble: View {
    let message: ChatMessage
    @State private var isAppearing = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 1.0),
                                    Color(red: 0.1, green: 0.7, blue: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                    
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            GlassMorphicCard(
                                backgroundColor: Color(red: 0.15, green: 0.15, blue: 0.2),
                                blurRadius: 15,
                                cornerRadius: 12
                            ) {
                                EmptyView()
                            }
                        )
                    
                    Text(message.timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
            }
        }
        .scaleEffect(isAppearing ? 1.0 : 0.8, anchor: message.role == .user ? .bottomTrailing : .bottomLeading)
        .opacity(isAppearing ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isAppearing = true
            }
        }
    }
}

struct SwitchInputArea: View {
    @Binding var inputText: String
    let isLoading: Bool
    let onSend: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isLoading {
                LiquidProgressBar(progress: 0.6)
                    .padding(.horizontal, 16)
            }
            
            HStack(spacing: 12) {
                LiquidTextField(
                    text: $inputText,
                    placeholder: "Введите сообщение...",
                    icon: "message"
                )
                .focused($isFocused)
                
                Button(action: onSend) {
                    if isLoading {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.5, green: 1.0, blue: 0.8))
                    }
                }
                .frame(width: 44, height: 44)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                        blurRadius: 15,
                        cornerRadius: 10
                    ) {
                        EmptyView()
                    }
                )
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            }
            .padding(12)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.8),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ModelSelectorOverlay: View {
    @Binding var selectedModel: String
    @Binding var isShowing: Bool
    
    let availableModels = [
        ("claude-sonnet-4-20250514", "Claude Sonnet 4", "Самая мощная модель"),
        ("claude-3-opus", "Claude Opus", "Универсальная модель"),
        ("claude-3-sonnet", "Claude Sonnet", "Быстрая модель")
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            VStack(spacing: 16) {
                Text("Выбор модели")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    ForEach(availableModels, id: \.0) { id, name, description in
                        ModelOption(
                            id: id,
                            name: name,
                            description: description,
                            isSelected: selectedModel == id,
                            action: {
                                withAnimation {
                                    selectedModel = id
                                    isShowing = false
                                }
                            }
                        )
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                GlassMorphicCard(
                    backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                    blurRadius: 25,
                    cornerRadius: 20
                ) {
                    EmptyView()
                }
            )
            .padding(16)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

struct ModelOption: View {
    let id: String
    let name: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
            }
        }
        .padding(12)
        .background(
            isSelected ?
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.2),
                    Color(red: 0.5, green: 1.0, blue: 0.8).opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(white: 0.15),
                    Color(white: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}

struct SwitchSettingsOverlay: View {
    @Binding var isShowing: Bool
    @State private var temperature: Double = 0.7
    @State private var maxTokens: Double = 2048
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            VStack(spacing: 20) {
                HStack {
                    Text("Параметры")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Температура")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Slider(value: $temperature, in: 0...2)
                            .tint(Color(red: 0.2, green: 0.8, blue: 1.0))
                        
                        Text(String(format: "%.1f", temperature))
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Максимум токенов")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Slider(value: $maxTokens, in: 256...4096, step: 256)
                            .tint(Color(red: 0.2, green: 0.8, blue: 1.0))
                        
                        Text(String(format: "%.0f", maxTokens))
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                GlassMorphicCard(
                    backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                    blurRadius: 25,
                    cornerRadius: 20
                ) {
                    EmptyView()
                }
            )
            .padding(16)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    SwitchMainChatView()
        .environmentObject(SwitchAPIClient.shared)
}
