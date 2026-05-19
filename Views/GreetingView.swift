import SwiftUI

struct GreetingView: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var titleAppear = false

    var body: some View {
        VStack(spacing: 22) {
            Spacer()

            SparkleIcon(size: 78)

            VStack(spacing: 6) {
                Text("Привет, \(settings.username)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                Text("Чем могу помочь?")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.65))
            }
            .opacity(titleAppear ? 1 : 0)
            .offset(y: titleAppear ? 0 : 14)

            SuggestionChips()
                .padding(.top, 6)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) { titleAppear = true }
        }
    }
}

private struct SuggestionChips: View {
    @EnvironmentObject private var vm: ChatViewModel

    private let suggestions: [(String, String)] = [
        ("Объясни код", "lightbulb.fill"),
        ("Помоги с письмом", "envelope.fill"),
        ("Идеи для презентации", "lightbulb"),
        ("Опиши изображение", "photo.fill")
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(suggestions, id: \.0) { suggestion in
                Button {
                    vm.draft = suggestion.0
                    vm.isComposing = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: suggestion.1)
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.95, green: 0.55, blue: 0.92))
                            .frame(width: 26, height: 26)
                            .background(
                                Circle().fill(Color.white.opacity(0.08))
                            )
                        Text(suggestion.0)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .liquidGlass(cornerRadius: 18, intensity: 0.65)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}
