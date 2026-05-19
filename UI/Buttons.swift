import SwiftUI

/// Round icon button styled like the buttons inside the Switch UI.
struct GlassIconButton: View {
    let systemImage: String
    var size: CGFloat = 44
    var fontSize: CGFloat = 18
    var tint: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(tint)
                .frame(width: size, height: size)
                .liquidGlassCircle(intensity: 0.8)
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

/// Button style that scales down and softens shadow when pressed.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.04 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Pill-shaped CTA used in dialogs.
struct GlassPillButton: View {
    let title: String
    let systemImage: String?
    var tint: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(tint)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .liquidGlassPill(intensity: 0.85)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
