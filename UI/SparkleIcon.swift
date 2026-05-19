import SwiftUI

/// 4-pointed rainbow "sparkle" — the brand mark used on the greeting screen.
struct SparkleIcon: View {

    var size: CGFloat = 48
    @State private var rotation: Double = 0
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Soft outer glow.
            sparkleShape
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.95, green: 0.45, blue: 0.30),
                            Color(red: 0.95, green: 0.85, blue: 0.30),
                            Color(red: 0.35, green: 0.85, blue: 0.55),
                            Color(red: 0.30, green: 0.60, blue: 0.95),
                            Color(red: 0.85, green: 0.30, blue: 0.85),
                            Color(red: 0.95, green: 0.45, blue: 0.30)
                        ]),
                        center: .center
                    )
                )
                .frame(width: size, height: size)
                .blur(radius: size * 0.18)
                .opacity(0.85)

            // Solid coloured sparkle.
            sparkleShape
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 1.00, green: 0.50, blue: 0.30),
                            Color(red: 1.00, green: 0.90, blue: 0.30),
                            Color(red: 0.40, green: 0.95, blue: 0.55),
                            Color(red: 0.30, green: 0.65, blue: 1.00),
                            Color(red: 0.90, green: 0.35, blue: 0.95),
                            Color(red: 1.00, green: 0.50, blue: 0.30)
                        ]),
                        center: .center
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(pulse)
                .shadow(color: .white.opacity(0.35), radius: size * 0.15)
        }
        .onAppear {
            withAnimation(.linear(duration: 24).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulse = 1.08
            }
        }
        .accessibilityHidden(true)
    }

    private var sparkleShape: some Shape {
        SparkleShape()
    }
}

private struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) / 2
        let inner = r * 0.32
        let waist = r * 0.10

        // 4 cardinal points + 4 waist points = 8-point star with smooth curve.
        let pts: [CGPoint] = [
            CGPoint(x: cx, y: cy - r),
            CGPoint(x: cx + waist, y: cy - inner),
            CGPoint(x: cx + r, y: cy),
            CGPoint(x: cx + waist, y: cy + inner),
            CGPoint(x: cx, y: cy + r),
            CGPoint(x: cx - waist, y: cy + inner),
            CGPoint(x: cx - r, y: cy),
            CGPoint(x: cx - waist, y: cy - inner)
        ]

        path.move(to: pts[0])
        for i in 1..<pts.count {
            let cur = pts[i]
            let prev = pts[i - 1]
            let mid = CGPoint(x: (cur.x + prev.x) / 2, y: (cur.y + prev.y) / 2)
            path.addQuadCurve(to: cur, control: mid)
        }
        path.closeSubpath()
        return path
    }
}
