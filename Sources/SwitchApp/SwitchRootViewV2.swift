import SwiftUI

// MARK: - Switch Root View V2
// This file implements the expanded navigation and layout system.

struct SwitchRootViewV2: View {
    @EnvironmentObject var appState: SwitchAppState
    @EnvironmentObject var apiClient: SwitchAIClient
    @StateObject var core = SwitchCoreEngine.shared
    
    @State private var showSidebar = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Layer
            PremiumMeshBackground()
            
            // Main Content Layer
            HStack(spacing: 0) {
                // Sidebar
                SidebarView()
                    .frame(width: 280)
                    .offset(x: showSidebar ? 0 : -280)
                
                // Main Screen
                ZStack {
                    VStack(spacing: 0) {
                        SwitchTopBarV2(showSidebar: $showSidebar)
                        
                        Group {
                            switch appState.activeScreen {
                            case .chat:
                                SwitchChatView()
                            case .tools:
                                SwitchToolsViewV2()
                            case .history:
                                SwitchHistoryViewV2()
                            case .settings:
                                SwitchSettingsViewV2()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        SwitchTabBarV2()
                    }
                    .padding(.horizontal, 16)
                    .background(
                        Color.black.opacity(showSidebar ? 0.3 : 0)
                            .onTapGesture {
                                withAnimation(SwitchDesignV2.springStandard) {
                                    showSidebar = false
                                }
                            }
                    )
                }
                .frame(width: UIScreen.main.bounds.width)
                .offset(x: showSidebar ? 0 : 0) // Main content stays or shifts
            }
            .offset(x: showSidebar ? 280 : 0)
            
            // Overlay Notifications
            if let notification = appState.notification {
                SwitchToast(notification: notification)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.startLocation.x < 50 && value.translation.width > 0 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        withAnimation(SwitchDesignV2.springStandard) {
                            showSidebar = true
                        }
                    }
                    dragOffset = 0
                }
        )
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @EnvironmentObject var appState: SwitchAppState
    @StateObject var core = SwitchCoreEngine.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Profile Header
            HStack(spacing: 12) {
                GlassIcon(systemName: "person.fill", color: .blue, size: 50)
                VStack(alignment: .leading, spacing: 2) {
                    Text(core.userProfile.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text(core.userProfile.tier)
                        .font(.system(size: 12))
                        .foregroundColor(SwitchPalette.electricBlue)
                }
            }
            .padding(.top, 60)
            
            // Conversation List
            VStack(alignment: .leading, spacing: 16) {
                Text("НЕДАВНИЕ ЧАТЫ")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(core.conversations) { conv in
                            SidebarItem(title: conv.title, icon: "message", isSelected: core.currentConversationId == conv.id) {
                                core.currentConversationId = conv.id
                                appState.activeScreen = .chat
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Bottom Actions
            VStack(spacing: 12) {
                SidebarItem(title: "Новый чат", icon: "plus.circle.fill", isSelected: false) {
                    _ = core.createNewConversation()
                }
                SidebarItem(title: "Настройки", icon: "gearshape.fill", isSelected: false) {
                    appState.activeScreen = .settings
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .background(Color.black.opacity(0.8))
        .background(.ultraThinMaterial)
    }
}

struct SidebarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                Spacer()
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

// MARK: - Expanded Views
struct SwitchToolsViewV2: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: "Инструменты", subtitle: "Специализированные AI-агенты")
                AgentGrid { agent in
                    // Handle agent selection
                }
                
                SectionTitle(title: "Аналитика", subtitle: "Ваша статистика использования")
                AnalyticsDashboard()
            }
            .padding(.vertical, 20)
        }
    }
}

struct SwitchHistoryViewV2: View {
    @StateObject var core = SwitchCoreEngine.shared
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                SectionTitle(title: "История", subtitle: "Все ваши разговоры")
                ForEach(core.conversations) { conv in
                    PremiumCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(conv.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("\(conv.messages.count) сообщений • \(conv.updatedAt.formatted())")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct SwitchSettingsViewV2: View {
    @StateObject var core = SwitchCoreEngine.shared
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: "Настройки", subtitle: "Персонализация и аккаунт")
                
                PremiumCard {
                    VStack(spacing: 20) {
                        ToggleRow(title: "Haptic Feedback", isOn: $core.appSettings.hapticsEnabled)
                        ToggleRow(title: "Stream Responses", isOn: $core.appSettings.streamEnabled)
                        ToggleRow(title: "Auto Save", isOn: $core.appSettings.autoSaveEnabled)
                    }
                }
                
                PremiumCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("АККАУНТ")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white.opacity(0.4))
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(core.userProfile.email)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        HStack {
                            Text("Подписка")
                            Spacer()
                            Text(core.userProfile.tier)
                                .foregroundColor(SwitchPalette.electricBlue)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var body: some View {
        Toggle(title, isOn: $isOn)
            .tint(SwitchPalette.electricBlue)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
    }
}

// MARK: - Updated Top Bar & Tab Bar
struct SwitchTopBarV2: View {
    @Binding var showSidebar: Bool
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(SwitchDesignV2.springStandard) {
                    showSidebar.toggle()
                }
            }) {
                GlassIcon(systemName: "line.3.horizontal", color: .white, size: 44)
            }
            
            Spacer()
            
            Text("SWITCH")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .tracking(4)
                .foregroundColor(.white)
            
            Spacer()
            
            GlassIcon(systemName: "sparkles", color: SwitchPalette.electricBlue, size: 44)
        }
        .padding(.vertical, 12)
    }
}

struct SwitchTabBarV2: View {
    @EnvironmentObject var appState: SwitchAppState
    var body: some View {
        HStack(spacing: 0) {
            ForEach(SwitchScreen.allCases) { screen in
                GlassToolbarItem(
                    icon: screen.icon,
                    title: screen.rawValue,
                    isSelected: appState.activeScreen == screen
                ) {
                    withAnimation(SwitchDesignV2.springStandard) {
                        appState.activeScreen = screen
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.bottom, 20)
    }
}
