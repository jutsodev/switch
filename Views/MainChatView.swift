import SwiftUI

struct MainChatView: View {
    @ObservedObject var viewModel: GeminiViewModel

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var greetingOffset: CGFloat = 20
    @State private var greetingOpacity: Double = 0.0

    var body: some View {
        ZStack {
            if viewModel.messages.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                messageList
            }

            liquidationOverlay
        }
        .onAppear {
            animateIn()
        }
        .onChange(of: viewModel.messages) { _, _ in
            if !viewModel.messages.isEmpty {
                withAnimation(.easeOut(duration: 0.3)) {
                    logoOpacity = 0.0
                    greetingOpacity = 0.0
                }
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            geminiLogo
            greetingText
        }
    }

    private var geminiLogo: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.5, blue: 1.0),
                            Color(red: 0.15, green: 0.25, blue: 0.7),
                            Color(red: 0.05, green: 0.1, blue: 0.4)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color(red: 0.3, green: 0.5, blue: 1.0).opacity(0.4), radius: 20)

            Image(systemName: "sparkles")
                .font(.system(size: 36, weight: .regular))
                .foregroundColor(.white)
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }

    private var greetingText: some View {
        VStack(spacing: 8) {
            Text("Привет, дима!")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)

            Text("Что вас интересует?")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
        .offset(y: greetingOffset)
        .opacity(greetingOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                greetingOffset = 0
                greetingOpacity = 1.0
            }
        }
    }

    private var messageList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.messages) { message in
                    MessageBubble(message: message)
                }

                if viewModel.isLoading {
                    loadingIndicator
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var loadingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.3, green: 0.5, blue: 1.0))
                    .frame(width: 8, height: 8)
                    .scaleEffect(0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(i) * 0.2),
                        value: viewModel.isLoading
                    )
            }
        }
        .padding()
    }

    private var liquidationOverlay: some View {
        ZStack {
            ForEach(viewModel.liquidationQueue) { file in
                if let index = viewModel.liquidationQueue.firstIndex(where: { $0.id == file.id }) {
                    EyeLiquidationToast(
                        file: file,
                        service: FileRemovalService()
                    )
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .gemini {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.3, green: 0.5, blue: 1.0),
                                Color(red: 0.2, green: 0.3, blue: 0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    if !message.attachedFiles.isEmpty {
                        attachmentsView
                    }
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: 280, alignment: .leading)
                .padding(14)
                .background(Color(white: 0.14))
                .cornerRadius(16)

                Spacer()
            } else {
                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundColor(.white)

                    if !message.attachedFiles.isEmpty {
                        attachmentsView
                    }
                }
                .frame(maxWidth: 280, alignment: .trailing)
                .padding(14)
                .background(Color(red: 0.2, green: 0.35, blue: 0.7))
                .cornerRadius(16)
            }
        }
    }

    private var attachmentsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(message.attachedFiles) { file in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(white: 0.2))
                            .frame(width: 48, height: 48)

                        Image(systemName: file.type.iconName)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    MainChatView(viewModel: GeminiViewModel())
        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
}