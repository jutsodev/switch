import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var store: ConversationStore
    @Environment(\.dismiss) private var dismiss

    @State private var revealKey: Bool = false
    @State private var confirmDeleteAll: Bool = false

    var body: some View {
        ZStack {
            AuroraBackground(intensity: 0.7).opacity(0.5)
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(spacing: 18) {
                        userSection
                        modelSection
                        apiSection
                        appearanceSection
                        dataSection
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Удалить все чаты?", isPresented: $confirmDeleteAll) {
            Button("Отменить", role: .cancel) {}
            Button("Удалить", role: .destructive) { store.deleteAll() }
        } message: {
            Text("Это действие нельзя отменить.")
        }
    }

    private var header: some View {
        HStack {
            Text("Настройки")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.55))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    private var userSection: some View {
        section(title: "Профиль") {
            VStack(spacing: 12) {
                row(label: "Имя") {
                    TextField("Имя", text: $settings.username)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.words)
                }
            }
        }
    }

    private var modelSection: some View {
        section(title: "Модель") {
            VStack(spacing: 8) {
                ForEach(SwitchModel.all) { model in
                    Button {
                        settings.selectModel(model)
                    } label: {
                        HStack {
                            Text(model.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: settings.selectedModelID == model.id ?
                                  "checkmark.circle.fill" : "circle")
                                .foregroundColor(settings.selectedModelID == model.id
                                                 ? Color(red: 0.95, green: 0.55, blue: 0.92)
                                                 : .white.opacity(0.35))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                }

                Picker("Уровень рассуждений", selection: $settings.reasoning) {
                    ForEach(ReasoningLevel.allCases) { level in
                        Text(level.title).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var apiSection: some View {
        section(title: "API") {
            VStack(spacing: 12) {
                row(label: "Базовый URL") {
                    TextField(APIClient.defaultBaseURL.absoluteString, text: $settings.baseURLOverride)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                row(label: "Ключ") {
                    HStack(spacing: 6) {
                        if revealKey {
                            TextField("sk-…", text: $settings.apiKeyOverride)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField("sk-…", text: $settings.apiKeyOverride)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        Button { revealKey.toggle() } label: {
                            Image(systemName: revealKey ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text("Если оба поля пустые, используются встроенные значения. Ключ хранится только локально.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var appearanceSection: some View {
        section(title: "Поведение") {
            VStack(spacing: 10) {
                Toggle("Потоковая генерация", isOn: $settings.streamingEnabled)
                Toggle("Тактильный отклик", isOn: $settings.hapticsEnabled)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Интенсивность liquid glass")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                        Text(String(format: "%.0f%%", settings.liquidIntensity * 100))
                            .font(.system(size: 13, weight: .semibold).monospacedDigit())
                            .foregroundColor(.white.opacity(0.55))
                    }
                    Slider(value: $settings.liquidIntensity, in: 0.3...1.2)
                        .tint(Color(red: 0.95, green: 0.55, blue: 0.92))
                }
            }
        }
    }

    private var dataSection: some View {
        section(title: "Данные") {
            VStack(spacing: 10) {
                Button(role: .destructive) {
                    confirmDeleteAll = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Удалить все чаты")
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.red.opacity(0.18))
                    )
                    .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var aboutSection: some View {
        section(title: "О приложении") {
            VStack(alignment: .leading, spacing: 6) {
                Text("Switch — клиент для Claude Sonnet через api.ecomagent.in.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.75))
                Text("Версия 1.0.0")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.45))
            }
        }
    }

    // MARK: - Helpers

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.leading, 6)
            VStack(spacing: 0) {
                content()
            }
            .padding(14)
            .liquidGlass(cornerRadius: 18, intensity: 0.65)
        }
    }

    private func row<Trailing: View>(
        label: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 14))
            Spacer()
            trailing()
                .font(.system(size: 14))
        }
        .padding(.vertical, 4)
    }
}
