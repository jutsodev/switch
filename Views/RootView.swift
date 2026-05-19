import SwiftUI

/// Root container: aurora background, chat, drawer / sheets stacked above.
struct RootView: View {
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var store: ConversationStore
    @StateObject private var vm: ChatViewModel

    init(store: ConversationStore, settings: SettingsStore, api: APIClient) {
        _vm = StateObject(wrappedValue: ChatViewModel(store: store, settings: settings, api: api))
    }

    var body: some View {
        ZStack {
            AuroraBackground(intensity: settings.liquidIntensity)

            ChatView()
                .environmentObject(vm)

            // Slide-in sidebar.
            if vm.showSidebar {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.spring) { vm.showSidebar = false } }
                    .transition(.opacity)

                SidebarView()
                    .environmentObject(vm)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // Error banner.
            if let err = vm.errorBanner {
                VStack {
                    ErrorBanner(message: err, onDismiss: { vm.dismissError() })
                        .padding(.horizontal, 16)
                        .padding(.top, 60)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $vm.showSettings) {
            SettingsView().environmentObject(vm)
        }
        .sheet(isPresented: $vm.showModelPicker) {
            ModelPickerView().environmentObject(vm)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $vm.showToolsSheet) {
            ToolsSheet().environmentObject(vm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $vm.showVoiceMode) {
            VoiceModeView().environmentObject(vm)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: vm.showSidebar)
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: vm.errorBanner)
    }
}

private struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(3)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 16, intensity: 0.95)
    }
}
