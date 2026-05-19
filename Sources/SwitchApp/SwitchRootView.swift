import SwiftUI

struct SwitchRootView: View {
    @EnvironmentObject var appState: SwitchAppState
    @EnvironmentObject var apiClient: SwitchAIClient

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            VStack(spacing: 0) {
                SwitchTopBar()
                Group {
                    switch appState.activeScreen {
                    case .chat: SwitchChatView()
                    case .tools: SwitchToolsView()
                    case .history: SwitchHistoryView()
                    case .settings: SwitchSettingsView()
                    }
                }
                SwitchTabBar()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            if let notification = appState.notification { SwitchToast(notification: notification).transition(.move(edge: .top).combined(with: .opacity)) }
        }
    }
}

struct SwitchTopBar: View {
    @EnvironmentObject var appState: SwitchAppState
    @EnvironmentObject var apiClient: SwitchAIClient

    var body: some View {
        HStack(spacing: 12) {
            GlassIcon(systemName: "switch.2", color: appState.accent.primary, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("Switch")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(apiClient.isLoading ? "думает…" : appState.selectedModel.displayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(SwitchPalette.textSecondary)
            }
            Spacer()
            Menu {
                ForEach(SwitchModel.all) { model in
                    Button(model.displayName) {
                        appState.selectedModel = model
                        apiClient.use(model: model)
                        appState.present("Модель: \(model.displayName)")
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: appState.selectedModel.icon)
                    Text("Model")
                }
            }
            .buttonStyle(LiquidGlassButtonStyle(tint: appState.accent.primary))
            Button { apiClient.reset(model: appState.selectedModel); appState.present("Чат очищен") } label: { Image(systemName: "plus") }
                .buttonStyle(LiquidGlassButtonStyle(tint: .gray))
        }
        .padding(.bottom, 12)
    }
}

struct SwitchChatView: View {
    @EnvironmentObject var appState: SwitchAppState
    @EnvironmentObject var apiClient: SwitchAIClient
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 14) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        HeroPanel().padding(.top, 4)
                        ForEach(apiClient.conversation.messages) { message in
                            SwitchMessageBubble(message: message)
                                .id(message.id)
                        }
                        if apiClient.isLoading { TypingIndicator().id("typing") }
                    }
                    .padding(.vertical, 4)
                }
                .onChange(of: apiClient.conversation.messages.count) { _ in
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) { proxy.scrollTo(apiClient.conversation.messages.last?.id, anchor: .bottom) }
                }
                .onChange(of: apiClient.isLoading) { loading in
                    if loading { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
                }
            }
            Composer(focused: $focused)
        }
    }
}

struct HeroPanel: View {
    @EnvironmentObject var appState: SwitchAppState
    var body: some View {
        LiquidGlassCard(cornerRadius: 32) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Liquid Glass AI workspace")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Чёрный, белый, серый и глубокий синий. Плавные карточки, живой фон и реальный Switch API.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(SwitchPalette.textSecondary)
                    }
                    Spacer()
                    GlassIcon(systemName: "sparkles", color: appState.accent.primary, size: 54)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(appState.quickPrompts) { prompt in
                        QuickPromptCard(prompt: prompt)
                    }
                }
            }
        }
        .premiumShimmer()
    }
}

struct QuickPromptCard: View {
    @EnvironmentObject var apiClient: SwitchAIClient
    let prompt: QuickPrompt
    var body: some View {
        Button {
            apiClient.inputText = prompt.title + ": "
        } label: {
            HStack(spacing: 10) {
                GlassIcon(systemName: prompt.icon, color: .blue, size: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(prompt.title).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    Text(prompt.subtitle).font(.system(size: 11)).foregroundStyle(SwitchPalette.textSecondary).lineLimit(2)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.055)))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08)))
        }
        .buttonStyle(.plain)
    }
}

struct SwitchMessageBubble: View {
    let message: SwitchChatMessage
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser { Spacer(minLength: 42) }
            if !message.isUser { GlassIcon(systemName: "sparkles", color: .blue, size: 34) }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                Text(message.content)
                    .font(.system(size: 15.5, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .textSelection(.enabled)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(message.isUser ? SwitchPalette.electricBlue.opacity(0.78) : Color.white.opacity(0.075))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    )
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(message.isUser ? 0.22 : 0.12), lineWidth: 1))
                HStack(spacing: 8) {
                    Text(message.timeLabel)
                    if message.state == .failed { Image(systemName: "exclamationmark.triangle.fill") }
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(message.state == .failed ? .red.opacity(0.9) : SwitchPalette.textSecondary)
            }
            if message.isUser { GlassIcon(systemName: "person.fill", color: .gray, size: 34) }
            if !message.isUser { Spacer(minLength: 42) }
        }
    }
}

struct TypingIndicator: View {
    @State private var phase = false
    var body: some View {
        HStack {
            GlassIcon(systemName: "ellipsis", color: .blue, size: 34)
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle().fill(Color.white.opacity(0.85)).frame(width: 7, height: 7).scaleEffect(phase ? 1.0 : 0.55).animation(.easeInOut(duration: 0.62).repeatForever().delay(Double(index) * 0.12), value: phase)
                }
            }
            .padding(14)
            .background(.ultraThinMaterial, in: Capsule())
            Spacer()
        }.onAppear { phase = true }
    }
}

struct Composer: View {
    @EnvironmentObject var appState: SwitchAppState
    @EnvironmentObject var apiClient: SwitchAIClient
    var focused: FocusState<Bool>.Binding

    var body: some View {
        LiquidGlassCard(cornerRadius: 30, intensity: 0.86) {
            VStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 10) {
                    TextField("Спросите Switch…", text: $apiClient.inputText, axis: .vertical)
                        .lineLimit(1...6)
                        .focused(focused)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.black.opacity(0.26)))
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.12)))
                    Button {
                        Task { await apiClient.sendCurrentMessage() }
                    } label: {
                        Image(systemName: apiClient.isLoading ? "hourglass" : "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .frame(width: 44, height: 44)
                    }
                    .disabled(apiClient.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || apiClient.isLoading)
                    .buttonStyle(LiquidGlassButtonStyle(tint: appState.accent.primary))
                }
                HStack(spacing: 10) {
                    ToolbarPill(icon: "paperclip", label: "Файл")
                    ToolbarPill(icon: "mic.fill", label: "Голос")
                    ToolbarPill(icon: "paintbrush.pointed.fill", label: "Canvas")
                    Spacer()
                    Text(apiClient.responseLatency.map { String(format: "%.1fs", $0) } ?? "online")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(SwitchPalette.textSecondary)
                }
            }
        }
        .padding(.bottom, 8)
    }
}

struct ToolbarPill: View {
    let icon: String
    let label: String
    var body: some View {
        HStack(spacing: 6) { Image(systemName: icon); Text(label) }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.86))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Capsule().fill(Color.white.opacity(0.07)))
            .overlay(Capsule().stroke(Color.white.opacity(0.08)))
    }
}
