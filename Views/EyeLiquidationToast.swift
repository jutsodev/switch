import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct EyeLiquidationToast: View {
    let file: FileItem
    @ObservedObject var service: FileRemovalService

    @State private var scale: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    @State private var eyeScale: CGFloat = 0.0
    @State private var blurRadius: CGFloat = 0.0
    @State private var particleOffset: [CGPoint] = []
    @State private var edgeOpacity: Double = 0.0

    private let context = CIContext()

    var body: some View {
        ZStack {
            toastBubble

            if service.animationPhase == .focus || service.animationPhase == .liquidation {
                eyeCore
            }

            if service.animationPhase == .liquidation {
                particlesView
            }
        }
        .onChange(of: service.animationPhase) { _, newPhase in
            animateForPhase(newPhase)
        }
        .onAppear {
            animateForPhase(.enrichment)
        }
    }

    private var toastBubble: some View {
        ZStack {
            Circle()
                .fill(service.toastBackgroundColor)
                .frame(width: 80, height: 80)
                .blur(radius: blurRadius)

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            centerGradientColor,
                            service.toastBackgroundColor
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)

            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.4),
                            Color.white.opacity(0.1),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 80, height: 80)

            Circle()
                .fill(backgroundForType)
                .frame(width: 56, height: 56)

            Image(systemName: file.type.iconName)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }

    private var eyeCore: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.7, green: 0.8, blue: 1.0).opacity(0.9),
                            Color(red: 0.3, green: 0.4, blue: 0.9).opacity(0.7),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 36, height: 36)

            Circle()
                .fill(Color(red: 0.08, green: 0.1, blue: 0.2))
                .frame(width: 16, height: 16)

            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 6, height: 6)
                .offset(x: 3, y: -3)
        }
        .scaleEffect(eyeScale)
        .opacity(service.eyeOpacity)
    }

    private var particlesView: some View {
        ForEach(0..<12, id: \.self) { index in
            let angle = Double(index) * (2 * .pi / 12)
            let startRadius: CGFloat = 30
            let endRadius: CGFloat = 80

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.5, blue: 1.0).opacity(0.6),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 4
                    )
                )
                .frame(width: 8, height: 8)
                .offset(
                    x: cos(angle) * (startRadius + (endRadius - startRadius) * CGFloat(service.currentProgress)),
                    y: sin(angle) * (startRadius + (endRadius - startRadius) * CGFloat(service.currentProgress))
                )
                .opacity(1.0 - service.currentProgress)
        }
    }

    private func animateForPhase(_ phase: FileRemovalService.AnimationPhase) {
        switch phase {
        case .idle:
            scale = 0.0
            opacity = 0.0
            eyeScale = 0.0
            blurRadius = 0.0

        case .enrichment:
            withAnimation(.easeOut(duration: 0.2)) {
                scale = 1.3
                opacity = 1.0
                blurRadius = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                service.currentProgress = 0.33
            }

        case .focus:
            withAnimation(.easeInOut(duration: 0.2)) {
                scale = 1.5
                blurRadius = 2.0
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                eyeScale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                service.currentProgress = 0.66
            }

        case .liquidation:
            withAnimation(.easeIn(duration: 0.35)) {
                scale = 0.4
                opacity = 0.0
                blurRadius = 15.0
                eyeScale = 0.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.3)) {
                    service.currentProgress = 1.0
                }
            }

        case .completed:
            scale = 0.0
            opacity = 0.0
            eyeScale = 0.0
            blurRadius = 30.0
        }
    }

    private var centerGradientColor: Color {
        switch file.type {
        case .image:
            return Color(red: 0.3, green: 0.5, blue: 1.0)
        case .document:
            return Color(red: 0.5, green: 0.5, blue: 0.7)
        case .audio:
            return Color(red: 0.6, green: 0.3, blue: 0.8)
        case .video:
            return Color(red: 0.8, green: 0.3, blue: 0.3)
        case .other:
            return Color(red: 0.4, green: 0.4, blue: 0.5)
        }
    }

    private var backgroundForType: Color {
        switch file.type {
        case .image:
            return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .document:
            return Color(red: 0.4, green: 0.4, blue: 0.5)
        case .audio:
            return Color(red: 0.5, green: 0.2, blue: 0.6)
        case .video:
            return Color(red: 0.6, green: 0.2, blue: 0.2)
        case .other:
            return Color(red: 0.3, green: 0.3, blue: 0.4)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.08)
        EyeLiquidationToast(
            file: FileItem(name: "photo.jpg", type: .image),
            service: FileRemovalService()
        )
    }
}