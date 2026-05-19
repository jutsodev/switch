import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.isAssistant {
                assistantAvatar
                assistantBubble
                Spacer(minLength: 24)
            } else {
                Spacer(minLength: 32)
                userBubble
            }
        }
    }

    private var assistantAvatar: some View {
        SparkleIcon(size: 26)
            .padding(.top, 4)
    }

    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 6) {
            if message.content.isEmpty && message.isStreaming {
                ThinkingDots()
                    .padding(.vertical, 6)
            } else {
                Text(message.content)
                    .font(.system(size: 15.5))
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !message.isStreaming && !message.content.isEmpty {
                MessageToolbar(message: message)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 20, intensity: 0.78)
        .frame(maxWidth: 320, alignment: .leading)
    }

    private var userBubble: some View {
        Text(message.content)
            .font(.system(size: 15.5, weight: .medium))
            .foregroundColor(.white)
            .textSelection(.enabled)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.30, blue: 0.55),
                                    Color(red: 0.60, green: 0.20, blue: 0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.30), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.plusLighter)
                        .mask(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(lineWidth: 1)
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.20), lineWidth: 0.6)
            )
            .shadow(color: Color(red: 0.60, green: 0.20, blue: 0.95).opacity(0.45), radius: 14, x: 0, y: 8)
            .frame(maxWidth: 280, alignment: .trailing)
    }
}

private struct MessageToolbar: View {
    let message: ChatMessage
    @State private var copied: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Button { copy() } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .buttonStyle(.plain)
            Button { } label: {
                Image(systemName: "hand.thumbsup")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
            }
            .buttonStyle(.plain)
            Button { } label: {
                Image(systemName: "hand.thumbsdown")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
            }
            .buttonStyle(.plain)
            Spacer()
            Text(timeString)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }

    private func copy() {
        #if canImport(UIKit)
        UIPasteboard.general.string = message.content
        #endif
        copied = true
        Haptics.tap()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            copied = false
        }
    }
}

private struct ThinkingDots: View {
    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 7, height: 7)
                    .scaleEffect(pulse ? 1.0 : 0.55)
                    .opacity(pulse ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.16),
                        value: pulse
                    )
            }
        }
        .onAppear { pulse = true }
    }
}
