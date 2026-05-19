import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GeminiUIViewModel()
    @StateObject private var dataStore = DataStore()
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showModelMenu = false
    @State private var showToolsMenu = false
    
    var body: some View {
        ZStack {
            Color("backgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                StatusBarView()
                
                HeaderView(viewModel: viewModel)
                
                if viewModel.displayedChatMessages.isEmpty {
                    CentralLogoView()
                } else {
                    ChatMessagesView(messages: viewModel.displayedChatMessages)
                }
                
                Spacer()
            }
            
            if viewModel.uiState.isModelMenuOpen {
                ModelSelectionMenuView(viewModel: viewModel)
                    .environmentObject(dataStore)
                    .transition(.opacity)
                    .zIndex(100)
            }
            
            if viewModel.uiState.isToolsMenuOpen {
                ToolsMenuView(viewModel: viewModel)
                    .environmentObject(dataStore)
                    .transition(.opacity)
                    .zIndex(100)
            }
            
            VStack {
                Spacer()
                
                InputFieldView(viewModel: viewModel)
            }
            .ignoresSafeArea(.keyboard)
        }
        .environmentObject(viewModel)
    }
}

struct ChatMessagesView: View {
    let messages: [ChatMessage]
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(messages) { message in
                        ChatMessageBubbleView(message: message)
                            .id(message.id)
                    }
                }
                .padding(16)
            }
            .onAppear {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id)
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

struct ChatMessageBubbleView: View {
    let message: ChatMessage
    @State private var isExpanded = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .assistant {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .textSelection(.enabled)
                    
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "hand.thumbsdown")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        Text(formatTime(message.timestamp))
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
            } else {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .textSelection(.enabled)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.0, green: 0.4, blue: 0.8))
                        .cornerRadius(12)
                    
                    Text(formatTime(message.timestamp))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                    .padding(.top, 8)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatInputCompactView: View {
    @Binding var text: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text("Введите сообщение")
                        .foregroundColor(.white.opacity(0.5))
                }
                .foregroundColor(.white)
                .font(.system(size: 14))
                .frame(height: 32)
                .padding(.horizontal, 10)
                .background(Color(white: 0.12))
                .cornerRadius(8)
            
            if !text.isEmpty {
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(white: 0.09))
    }
}

#Preview {
    ZStack {
        Color("backgroundColor")
            .ignoresSafeArea()
        
        ContentView()
            .environmentObject(AppCoordinator())
    }
}