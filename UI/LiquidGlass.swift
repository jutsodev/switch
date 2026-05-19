import SwiftUI

/// Visual primitives for the Switch "liquid glass" aesthetic.
///
/// We can't use iOS-26's real `.glassEffect()` modifier (not available in the
/// stable Xcode toolchain on the CI runner), so we approximate it with layered
/// material, gradient highlights, refractive overlays, and a subtle inner glow.

struct LiquidGlass: ViewModifier {
    var cornerRadius: CGFloat = 22
    var intensity: Double = 0.85
    var stroke: Bool = true

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // 1. Frosted material base.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // 2. Color wash so glass reads as glassy-tinted, not gray.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.10 * intensity),
                                    Color.white.opacity(0.02 * intensity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // 3. Specular highlight along the top edge.
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45 * intensity),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.plusLighter)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(lineWidth: 1.2)
                        )
                }
            )
            .overlay(
                Group {
                    if stroke {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35 * intensity),
                                        Color.white.opacity(0.05 * intensity),
                                        Color.white.opacity(0.20 * intensity)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.6
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 16)
    }
}

extension View {
    /// Apply liquid glass styling to any container.
    func liquidGlass(
        cornerRadius: CGFloat = 22,
        intensity: Double = 0.85,
        stroke: Bool = true
    ) -> some View {
        modifier(LiquidGlass(cornerRadius: cornerRadius, intensity: intensity, stroke: stroke))
    }
}

/// A capsule-shaped liquid glass pill — used for the input bar and chips.
struct LiquidGlassPill: ViewModifier {
    var intensity: Double = 0.9

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Capsule(style: .continuous).fill(.ultraThinMaterial)
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.10 * intensity),
                                    Color.white.opacity(0.02 * intensity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.40 * intensity),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.plusLighter)
                        .mask(Capsule(style: .continuous).stroke(lineWidth: 1.4))
                }
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35 * intensity),
                                Color.white.opacity(0.06 * intensity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.7
                    )
            )
            .clipShape(Capsule(style: .continuous))
            .shadow(color: Color.black.opacity(0.5), radius: 22, x: 0, y: 14)
    }
}

extension View {
    func liquidGlassPill(intensity: Double = 0.9) -> some View {
        modifier(LiquidGlassPill(intensity: intensity))
    }
}

/// Circular liquid glass for icon buttons.
struct LiquidGlassCircle: ViewModifier {
    var intensity: Double = 0.85

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Circle().fill(.ultraThinMaterial)
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12 * intensity),
                                    Color.white.opacity(0.03 * intensity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45 * intensity),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .blendMode(.plusLighter)
                        .mask(Circle().stroke(lineWidth: 1.2))
                }
            )
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35 * intensity),
                                Color.white.opacity(0.05 * intensity)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.7
                    )
            )
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.45), radius: 14, x: 0, y: 8)
    }
}

extension View {
    func liquidGlassCircle(intensity: Double = 0.85) -> some View {
        modifier(LiquidGlassCircle(intensity: intensity))
    }
}
