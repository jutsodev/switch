import SwiftUI

struct InputBar: View {
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var settings: SettingsStore
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 10) {
            inputRow

            HStack(spacing: 8) {
                ToolChip(systemImage: "photo", label: "Фото") { vm.showToolsSheet = true }
                ToolChip(systemImage: "camera", label: "Камера") { vm.showToolsSheet = true }
                ToolChip(systemImage: "folder", label: "Файлы") { vm.showToolsSheet = true }
                Spacer()
            }
            .padding(.horizontal, 6)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 28, intensity: 0.92)
    }

    private var inputRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Button {
                vm.showToolsSheet = true
                if settings.hapticsEnabled { Haptics.tap() }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .liquidGlassCircle(intensity: 0.65)
            }
            .buttonStyle(PressableButtonStyle())

            ZStack(alignment: .leading) {
                if vm.draft.isEmpty {
                    Text("Спросите Switch")
                        .foregroundColor(.white.opacity(0.55))
                        .font(.system(size: 16))
                        .padding(.horizontal, 6)
                }
                TextField("", text: $vm.draft, axis: .vertical)
                    .focused($focused)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .lineLimit(1...5)
                    .submitLabel(.send)
                    .padding(.horizontal, 6)
            }
            .frame(minHeight: 38)

            trailingButton
        }
        .padding(.horizontal, 6)
    }

    @ViewBuilder
    private var trailingButton: some View {
        let trimmed = vm.draft.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            Button {
                vm.showVoiceMode = true
                if settings.hapticsEnabled { Haptics.medium() }
            } label: {
                Image(systemName: "waveform")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .liquidGlassCircle(intensity: 0.7)
            }
            .buttonStyle(PressableButtonStyle())
        } else {
            Button {
                focused = false
                vm.send()
            } label: {
                Image(systemName: vm.isSending ? "stop.fill" : "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        ZStack {
                            Circle().fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.55, blue: 0.30),
                                        Color(red: 0.85, green: 0.30, blue: 0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            Circle().fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.35), .clear],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .blendMode(.plusLighter)
                            .mask(Circle().stroke(lineWidth: 1.2))
                        }
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(red: 0.85, green: 0.30, blue: 0.85).opacity(0.55), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(vm.isSending)
        }
    }
}

private struct ToolChip: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .liquidGlassPill(intensity: 0.6)
        }
        .buttonStyle(PressableButtonStyle())
    }
}


