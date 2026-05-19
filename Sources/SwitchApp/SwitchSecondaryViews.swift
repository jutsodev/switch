import SwiftUI

struct SwitchToolsView: View {
    @EnvironmentObject var apiClient: SwitchAIClient
    @EnvironmentObject var appState: SwitchAppState
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "Инструменты", subtitle: "Быстрые режимы для работы, кода и исследований")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(SwitchTool.catalog) { tool in
                        Button {
                            apiClient.inputText = tool.prompt + "\n"
                            appState.activeScreen = .chat
                        } label: { ToolTile(tool: tool) }
                        .buttonStyle(.plain)
                    }
                }
            }.padding(.vertical, 8)
        }
    }
}

struct ToolTile: View {
    let tool: SwitchTool
    var body: some View {
        LiquidGlassCard(cornerRadius: 26) {
            VStack(alignment: .leading, spacing: 12) {
                GlassIcon(systemName: tool.icon, color: tool.color, size: 46)
                Text(tool.title).font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(.white)
                Text(tool.subtitle).font(.system(size: 13, weight: .medium)).foregroundStyle(SwitchPalette.textSecondary).lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .minHeight(118)
        }
    }
}

struct SwitchHistoryView: View {
    @EnvironmentObject var apiClient: SwitchAIClient
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "История", subtitle: "Локальная история текущей сессии")
                ForEach(apiClient.conversation.messages) { message in
                    LiquidGlassCard(cornerRadius: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(message.role.rawValue.uppercased()).font(.system(size: 11, weight: .heavy)).foregroundStyle(.blue)
                                Spacer()
                                Text(message.timeLabel).font(.system(size: 11, weight: .medium)).foregroundStyle(SwitchPalette.textSecondary)
                            }
                            Text(message.content).font(.system(size: 14)).foregroundStyle(.white).lineLimit(4)
                        }
                    }
                }
            }.padding(.vertical, 8)
        }
    }
}

struct SwitchSettingsView: View {
    @EnvironmentObject var appState: SwitchAppState
    @EnvironmentObject var apiClient: SwitchAIClient
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                SectionTitle(title: "Настройки", subtitle: "Тема, модели, плавность и API")
                LiquidGlassCard(cornerRadius: 28) {
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Ambient motion", isOn: $appState.ambientMotion).tint(appState.accent.primary)
                        Toggle("Focus mode", isOn: $appState.focusMode).tint(appState.accent.primary)
                        VStack(alignment: .leading) {
                            Text("Liquid intensity").foregroundStyle(.white).font(.system(size: 14, weight: .semibold))
                            Slider(value: $appState.liquidIntensity, in: 0.25...1.0).tint(appState.accent.primary)
                        }
                        Picker("Accent", selection: $appState.accent) {
                            ForEach(SwitchAccent.allCases) { accent in Text(accent.rawValue).tag(accent) }
                        }.pickerStyle(.segmented)
                    }
                }
                LiquidGlassCard(cornerRadius: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("API").font(.system(size: 18, weight: .bold)).foregroundStyle(.white)
                        Text("Endpoint: https://api.ecomagent.in/v1")
                            .font(.system(size: 13, design: .monospaced)).foregroundStyle(SwitchPalette.textSecondary)
                        Text("Model: \(appState.selectedModel.id)")
                            .font(.system(size: 13, design: .monospaced)).foregroundStyle(SwitchPalette.textSecondary)
                        if let error = apiClient.lastError { Text(error).foregroundStyle(.red).font(.system(size: 12)) }
                    }
                }
            }.padding(.vertical, 8)
        }
    }
}

struct SwitchTabBar: View {
    @EnvironmentObject var appState: SwitchAppState
    var body: some View {
        HStack(spacing: 8) {
            ForEach(SwitchScreen.allCases) { screen in
                Button { withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) { appState.activeScreen = screen } } label: {
                    VStack(spacing: 4) {
                        Image(systemName: screen.icon).font(.system(size: 17, weight: .bold))
                        Text(screen.rawValue).font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(appState.activeScreen == screen ? .white : SwitchPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(appState.activeScreen == screen ? appState.accent.primary.opacity(0.52) : Color.white.opacity(0.05)))
                }.buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
        .padding(.bottom, 8)
    }
}

struct SwitchToast: View {
    let notification: SwitchNotification
    var body: some View {
        VStack { LiquidGlassCard(cornerRadius: 22) { HStack { Image(systemName: icon); Text(notification.message).font(.system(size: 14, weight: .semibold)); Spacer() }.foregroundStyle(.white) }.padding(.horizontal, 18).padding(.top, 12); Spacer() }
    }
    private var icon: String {
        switch notification.style { case .success: return "checkmark.circle.fill"; case .warning: return "exclamationmark.triangle.fill"; case .error: return "xmark.octagon.fill" }
    }
}

struct SectionTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 28, weight: .bold, design: .rounded)).foregroundStyle(.white)
            Text(subtitle).font(.system(size: 14, weight: .medium)).foregroundStyle(SwitchPalette.textSecondary)
        }
    }
}

extension View {
    func minHeight(_ value: CGFloat) -> some View { frame(minHeight: value) }
}
