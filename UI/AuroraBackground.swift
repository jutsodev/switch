import SwiftUI

/// Slow, drifting coloured blobs behind everything else. Gives the dark
/// background some life and provides material for the glass surfaces above
/// to refract.
struct AuroraBackground: View {

    @State private var phase: CGFloat = 0
    var intensity: Double = 0.9

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let t = CGFloat(context.date.timeIntervalSinceReferenceDate)
            Canvas { ctx, size in
                ctx.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .color(Color(red: 0.04, green: 0.04, blue: 0.07)))

                drawBlob(
                    in: ctx,
                    size: size,
                    center: CGPoint(
                        x: size.width * (0.30 + 0.08 * sin(t * 0.13)),
                        y: size.height * (0.18 + 0.05 * cos(t * 0.17))
                    ),
                    radius: size.width * 0.55,
                    color: Color(red: 0.30, green: 0.10, blue: 0.65)
                        .opacity(0.55 * intensity)
                )

                drawBlob(
                    in: ctx,
                    size: size,
                    center: CGPoint(
                        x: size.width * (0.70 + 0.10 * cos(t * 0.11)),
                        y: size.height * (0.30 + 0.07 * sin(t * 0.09))
                    ),
                    radius: size.width * 0.50,
                    color: Color(red: 0.85, green: 0.25, blue: 0.55)
                        .opacity(0.45 * intensity)
                )

                drawBlob(
                    in: ctx,
                    size: size,
                    center: CGPoint(
                        x: size.width * (0.50 + 0.20 * sin(t * 0.07)),
                        y: size.height * (0.75 + 0.05 * cos(t * 0.10))
                    ),
                    radius: size.width * 0.65,
                    color: Color(red: 0.20, green: 0.55, blue: 0.95)
                        .opacity(0.40 * intensity)
                )

                drawBlob(
                    in: ctx,
                    size: size,
                    center: CGPoint(
                        x: size.width * (0.15 + 0.15 * cos(t * 0.15)),
                        y: size.height * (0.85 + 0.07 * sin(t * 0.13))
                    ),
                    radius: size.width * 0.40,
                    color: Color(red: 0.10, green: 0.85, blue: 0.95)
                        .opacity(0.30 * intensity)
                )
            }
            .blur(radius: 80)
            .opacity(0.95)
            .background(Color.black)
        }
        .ignoresSafeArea()
        .drawingGroup()
    }

    private func drawBlob(
        in ctx: GraphicsContext,
        size: CGSize,
        center: CGPoint,
        radius: CGFloat,
        color: Color
    ) {
        let rect = CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        )
        let gradient = Gradient(stops: [
            .init(color: color, location: 0),
            .init(color: color.opacity(0.0), location: 1)
        ])
        ctx.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                gradient,
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
    }
}
