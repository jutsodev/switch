import SwiftUI

struct SwitchPalette {
    static let black = Color(red: 0.01, green: 0.012, blue: 0.018)
    static let graphite = Color(red: 0.04, green: 0.045, blue: 0.06)
    static let slate = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let deepBlue = Color(red: 0.02, green: 0.12, blue: 0.32)
    static let electricBlue = Color(red: 0.08, green: 0.42, blue: 1.0)
    static let cyan = Color(red: 0.14, green: 0.76, blue: 1.0)
    static let white = Color.white
    static let textSecondary = Color.white.opacity(0.62)
}

struct LiquidGlassBackground: View {
    @EnvironmentObject var appState: SwitchAppState
    @State private var animate = false

    var body: some View {
        ZStack {
            // Base Dark Layer
            Color.black.ignoresSafeArea()
            
            // Dynamic Mesh-like Gradient
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                
                Canvas { context, size in
                    context.addFilter(.blur(radius: 60))
                    
                    // Floating Orbs
                    let orbs = [
                        (appState.accent.primary.opacity(0.45), 0.2, 0.2, 0.4, 0.3),
                        (appState.accent.secondary.opacity(0.3), 0.8, 0.3, 0.5, 0.4),
                        (SwitchPalette.deepBlue.opacity(0.4), 0.5, 0.7, 0.6, 0.5),
                        (Color.white.opacity(0.08), 0.3, 0.8, 0.3, 0.2)
                    ]
                    
                    for (color, ox, oy, sw, sh) in orbs {
                        let dx = sin(t * sw) * 0.1
                        let dy = cos(t * sh) * 0.1
                        let rect = CGRect(
                            x: size.width * (ox + dx) - size.width * 0.3,
                            y: size.height * (oy + dy) - size.height * 0.3,
                            width: size.width * 0.8,
                            height: size.height * 0.8
                        )
                        context.fill(Path(ellipseIn: rect), with: .color(color))
                    }
                }
            }
            .ignoresSafeArea()
            
            // Noise / Grain Overlay
            Rectangle()
                .fill(.black.opacity(0.15))
                .overlay(
                    Image(systemName: "circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.02)
                        .blendMode(.overlay)
                )
                .ignoresSafeArea()
            
            // Interactive Particles
            LiquidParticleField(intensity: appState.liquidIntensity)
        }
    }
}

struct LiquidParticleField: View {
    var intensity: Double
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for i in 0..<42 {
                    let seed = Double(i)
                    let x = size.width * (0.5 + 0.45 * sin(seed * 1.4 + t * 0.2))
                    let y = size.height * (0.5 + 0.45 * cos(seed * 1.8 + t * 0.15))
                    let scale = 1.0 + 0.4 * sin(t + seed)
                    let diameter = CGFloat((12 + (i % 8) * 6)) * scale
                    
                    let rect = CGRect(x: x - diameter/2, y: y - diameter/2, width: diameter, height: diameter)
                    let opacity = (0.01 + intensity * 0.012) * (0.5 + 0.5 * sin(t * 0.5 + seed))
                    
                    context.opacity = opacity
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
            .blur(radius: 14)
        }
    }
}

struct LiquidGlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 32
    var intensity: Double = 0.82
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .background(
                ZStack {
                    // Glass Base
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(intensity)
                    
                    // Inner Glow
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.clear,
                                    Color.blue.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.45),
                                    Color.white.opacity(0.05),
                                    Color.blue.opacity(0.25),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 20)
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    var tint: Color = SwitchPalette.electricBlue
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    tint.opacity(configuration.isPressed ? 0.45 : 0.3),
                                    tint.opacity(configuration.isPressed ? 0.25 : 0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Capsule(style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct GlassIcon: View {
    let systemName: String
    var color: Color = SwitchPalette.electricBlue
    var size: CGFloat = 48
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            Image(systemName: systemName)
                .font(.system(size: size * 0.45, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: color.opacity(0.5), radius: 8)
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}

struct PremiumShimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.35), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + (geo.size.width * 2 * phase))
                }
            )
            .onAppear {
                withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
            .mask(content)
    }
}

extension View {
    func premiumShimmer() -> some View {
        modifier(PremiumShimmer())
    }
}
