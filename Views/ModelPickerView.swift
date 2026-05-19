import SwiftUI

struct ModelPickerView: View {
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AuroraBackground(intensity: 1.0).opacity(0.55)
            VStack(spacing: 12) {
                header

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(SwitchModel.all) { model in
                            row(for: model)
                        }

                        Text("Уровень рассуждений")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 18)
                            .padding(.leading, 4)

                        ForEach(ReasoningLevel.allCases) { level in
                            reasoningRow(for: level)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 20)
                }
            }
            .padding(.top, 18)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("Выберите модель")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.55))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
    }

    private func row(for model: SwitchModel) -> some View {
        let selected = settings.selectedModelID == model.id
        return Button {
            vm.selectModel(model)
            dismiss()
        } label: {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient(for: model),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: glyph(for: model))
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(model.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(selected ? Color(red: 0.95, green: 0.55, blue: 0.92) : .white.opacity(0.35))
            }
            .padding(14)
            .liquidGlass(cornerRadius: 18, intensity: selected ? 0.85 : 0.65, stroke: true)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func reasoningRow(for level: ReasoningLevel) -> some View {
        let selected = settings.reasoning == level
        return Button {
            settings.reasoning = level
            if settings.hapticsEnabled { Haptics.tap() }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: reasoningGlyph(level))
                    .frame(width: 24)
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(level.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(selected ? Color(red: 0.95, green: 0.55, blue: 0.92) : .white.opacity(0.35))
            }
            .padding(12)
            .liquidGlass(cornerRadius: 14, intensity: selected ? 0.8 : 0.55, stroke: true)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func gradient(for model: SwitchModel) -> [Color] {
        switch model.id {
        case SwitchModel.flashLite.id:
            return [Color(red: 0.30, green: 0.60, blue: 0.95), Color(red: 0.20, green: 0.80, blue: 0.95)]
        case SwitchModel.flash.id:
            return [Color(red: 0.95, green: 0.55, blue: 0.30), Color(red: 0.95, green: 0.30, blue: 0.85)]
        case SwitchModel.pro.id:
            return [Color(red: 0.55, green: 0.30, blue: 0.95), Color(red: 0.30, green: 0.60, blue: 0.95)]
        default:
            return [Color.gray, Color.gray]
        }
    }

    private func glyph(for model: SwitchModel) -> String {
        switch model.id {
        case SwitchModel.flashLite.id: return "bolt.fill"
        case SwitchModel.flash.id: return "sparkles"
        case SwitchModel.pro.id: return "brain.head.profile"
        default: return "circle"
        }
    }

    private func reasoningGlyph(_ level: ReasoningLevel) -> String {
        switch level {
        case .minimal: return "hare.fill"
        case .balanced: return "scale.3d"
        case .extensive: return "tortoise.fill"
        }
    }
}
