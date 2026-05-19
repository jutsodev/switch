import SwiftUI

struct TopBar: View {
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        HStack(spacing: 14) {
            GlassIconButton(
                systemImage: "line.3.horizontal",
                size: 40,
                fontSize: 17
            ) {
                withAnimation(.spring) { vm.showSidebar.toggle() }
            }
            .accessibilityLabel("История")

            Spacer()

            Button {
                vm.showModelPicker = true
                if settings.hapticsEnabled { Haptics.tap() }
            } label: {
                HStack(spacing: 6) {
                    Text("Switch")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(settings.selectedModel.name)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.65))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.65))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .liquidGlassPill(intensity: 0.85)
            }
            .buttonStyle(PressableButtonStyle())

            Spacer()

            GlassIconButton(
                systemImage: "square.and.pencil",
                size: 40,
                fontSize: 16
            ) {
                vm.startNewConversation()
            }
            .accessibilityLabel("Новый чат")
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 6)
    }
}
