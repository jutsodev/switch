import SwiftUI

/// Visual-only voice mode placeholder — a pulsing sparkle that approximates the
/// "talking with Switch" experience from the video. The actual speech pipeline
/// is intentionally out of scope for this build.
struct VoiceModeView: View {
    @EnvironmentObject private var vm: ChatViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var ringPhase: CGFloat = 0
    @State private var beating: Bool = false

    var body: some View {
        ZStack {
            AuroraBackground(intensity: 1.1).overlay(Color.black.opacity(0.2))

            VStack(spacing: 26) {
                Spacer()

                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.55, blue: 0.92),
                                        Color(red: 0.30, green: 0.60, blue: 0.95)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 180 + CGFloat(i) * 40,
                                   height: 180 + CGFloat(i) * 40)
                            .opacity(0.55 - Double(i) * 0.15)
                            .scaleEffect(beating ? 1.04 : 0.96)
                            .animation(
                                .easeInOut(duration: 2.2 + Double(i) * 0.3)
                                    .repeatForever(autoreverses: true),
                                value: beating
                            )
                    }
                    SparkleIcon(size: 120)
                }

                Text("Слушаю…")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)

                Text("Скажите что-нибудь — Switch ответит голосом.")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                HStack(spacing: 22) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .liquidGlassCircle(intensity: 0.85)
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        Haptics.medium()
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 90)
                            .background(
                                ZStack {
                                    Circle().fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.95, green: 0.55, blue: 0.92),
                                                Color(red: 0.55, green: 0.30, blue: 0.95)
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
                                    .mask(Circle().stroke(lineWidth: 1.4))
                                }
                            )
                            .clipShape(Circle())
                            .shadow(color: Color(red: 0.95, green: 0.55, blue: 0.92).opacity(0.55),
                                    radius: 22, x: 0, y: 10)
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        dismiss()
                        Haptics.medium()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .liquidGlassCircle(intensity: 0.85)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { beating = true }
    }
}
