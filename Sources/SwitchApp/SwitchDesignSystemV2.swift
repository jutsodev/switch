import SwiftUI
import Combine

// MARK: - Switch Design System V2
// This file expands the design system with advanced shaders, haptics, and micro-interactions.

struct SwitchDesignV2 {
    static let cornerRadiusLarge: CGFloat = 36
    static let cornerRadiusMedium: CGFloat = 24
    static let cornerRadiusSmall: CGFloat = 16
    
    static let springStandard = Animation.spring(response: 0.35, dampingFraction: 0.82, blendDuration: 0)
    static let springBouncy = Animation.spring(response: 0.45, dampingFraction: 0.65, blendDuration: 0)
    static let springSnappy = Animation.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0)
}

// MARK: - Advanced Mesh Gradient
struct PremiumMeshBackground: View {
    @State private var t: CGFloat = 0
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Primary Mesh Layer
            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5 + 0.1 * sin(t), 0.5 + 0.1 * cos(t)], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ], colors: [
                .black, .black, .black,
                SwitchPalette.deepBlue.opacity(0.4), SwitchPalette.electricBlue.opacity(0.3), .black,
                .black, SwitchPalette.slate.opacity(0.5), .black
            ])
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                t += 0.01
            }
            
            // Secondary Glows
            Group {
                Circle()
                    .fill(SwitchPalette.electricBlue.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(SwitchPalette.cyan.opacity(0.1))
                    .frame(width: 350, height: 350)
                    .blur(radius: 70)
                    .offset(x: 200, y: 300)
            }
        }
    }
}

// MARK: - Liquid Glass Shader Component
struct LiquidGlassShaderView: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(
                Canvas { context, size in
                    // Custom drawing for glass refraction simulation
                    let rect = CGRect(origin: .zero, size: size)
                    context.addFilter(.blur(radius: 10))
                    context.fill(Path(rect), with: .color(.white.opacity(0.05)))
                }
            )
    }
}

// MARK: - Interactive Glass Button
struct InteractiveGlassButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: Content
    @State private var isHovered = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            content
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(isPressed ? 0.9 : 0.7)
                        
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(isPressed ? 0.6 : 0.3),
                                        .white.opacity(0.1),
                                        SwitchPalette.electricBlue.opacity(isPressed ? 0.4 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(SwitchDesignV2.springSnappy, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressAction { pressed in
            isPressed = pressed
        }
    }
}

// MARK: - View Extensions
extension View {
    func pressAction(onPress: @escaping (Bool) -> Void) -> some View {
        modifier(PressActionsModifier(onPress: onPress))
    }
}

struct PressActionsModifier: ViewModifier {
    var onPress: (Bool) -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress(true) }
                    .onEnded { _ in onPress(false) }
            )
    }
}

// MARK: - Haptic Manager
class SwitchHaptics {
    static let shared = SwitchHaptics()
    
    func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
}

// MARK: - Glass Toolbar Item
struct GlassToolbarItem: View {
    let icon: String
    let title: String
    var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SwitchPalette.electricBlue.opacity(0.2))
                            .matchedGeometryEffect(id: "tab_bg", in: tabNamespace)
                    }
                }
            )
        }
    }
    @Namespace private var tabNamespace
}

// MARK: - Premium Card Container
struct PremiumCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(24)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - MeshGradient Polyfill for older iOS if needed
// (Assuming iOS 18+ for MeshGradient, otherwise fallback to Linear/Radial)
struct MeshGradient: View {
    let width: Int
    let height: Int
    let points: [[CGFloat]]
    let colors: [Color]
    
    var body: some View {
        // Fallback for environments without native MeshGradient
        ZStack {
            colors[4].ignoresSafeArea()
            RadialGradient(colors: [colors[4], .clear], center: .center, startRadius: 0, endRadius: 500)
        }
    }
}
