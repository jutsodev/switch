import SwiftUI

struct ToolsSheet: View {
    @EnvironmentObject private var vm: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AuroraBackground(intensity: 0.7).opacity(0.55)
            VStack(spacing: 18) {
                header

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SwitchTool.primaryTools) { tool in
                            primaryButton(for: tool)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                VStack(spacing: 8) {
                    ForEach(SwitchTool.advancedTools) { tool in
                        advancedRow(for: tool)
                    }
                }
                .padding(.horizontal, 14)

                Spacer(minLength: 0)
            }
            .padding(.top, 18)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("Инструменты")
                .font(.system(size: 19, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 21))
                    .foregroundColor(.white.opacity(0.55))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
    }

    private func primaryButton(for tool: SwitchTool) -> some View {
        Button {
            dismiss()
            Haptics.tap()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: tool.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .liquidGlassCircle(intensity: 0.75)
                Text(tool.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
            .frame(width: 78)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func advancedRow(for tool: SwitchTool) -> some View {
        Button {
            dismiss()
            Haptics.tap()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: tool.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .liquidGlassCircle(intensity: 0.65)
                Text(tool.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                if tool.isNew {
                    Text("Новинка")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.30, blue: 0.85),
                                             Color(red: 0.55, green: 0.30, blue: 0.95)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
            }
            .padding(12)
            .liquidGlass(cornerRadius: 16, intensity: 0.55)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
