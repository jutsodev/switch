import SwiftUI
import Combine

struct AdvancedAnimationLibrary {
    struct SpringPhysics {
        let stiffness: CGFloat
        let damping: CGFloat
        let mass: CGFloat
        
        static let snappy = SpringPhysics(stiffness: 300, damping: 10, mass: 1)
        static let bouncy = SpringPhysics(stiffness: 200, damping: 10, mass: 1)
        static let smooth = SpringPhysics(stiffness: 100, damping: 15, mass: 1)
    }
    
    struct TransitionEffect {
        let from: CGFloat
        let to: CGFloat
        let duration: Double
        let curve: Animation
        
        static func customFade(duration: Double = 0.3) -> TransitionEffect {
            TransitionEffect(
                from: 0,
                to: 1,
                duration: duration,
                curve: .easeInOut(duration: duration)
            )
        }
        
        static func slideLeft(distance: CGFloat = 50, duration: Double = 0.3) -> TransitionEffect {
            TransitionEffect(
                from: distance,
                to: 0,
                duration: duration,
                curve: .easeOut(duration: duration)
            )
        }
        
        static func slideRight(distance: CGFloat = 50, duration: Double = 0.3) -> TransitionEffect {
            TransitionEffect(
                from: -distance,
                to: 0,
                duration: duration,
                curve: .easeOut(duration: duration)
            )
        }
        
        static func scaleAndFade(duration: Double = 0.3) -> TransitionEffect {
            TransitionEffect(
                from: 0.5,
                to: 1,
                duration: duration,
                curve: .easeOut(duration: duration)
            )
        }
    }
}

struct MorphingShape: Shape {
    var progress: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startRadius = rect.width / 2 * (1 - progress)
        let endRadius = rect.width / 2 * progress
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.addEllipse(in: CGRect(
            x: center.x - startRadius,
            y: center.y - startRadius,
            width: startRadius * 2,
            height: startRadius * 2
        ))
        
        return path
    }
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGSize
    var rotation: Double
    var scale: CGFloat
    var opacity: Double
    var lifetime: Double
    
    mutating func update(deltaTime: Double) {
        position.x += velocity.width * deltaTime
        position.y += velocity.height * deltaTime
        velocity.height += 9.8 * deltaTime
        rotation += 720 * deltaTime
        opacity = max(0, opacity - deltaTime)
        scale *= 0.98
    }
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var displayLink: CADisplayLink?
    let emissionCount: Int
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.8, green: 0.2, blue: 0.0),
                                Color(red: 0.2, green: 0.4, blue: 0.9),
                                Color(red: 0.2, green: 0.8, blue: 0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 8, height: 8)
                    .position(particle.position)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            emitParticles()
            startDisplayLink()
        }
    }
    
    private func emitParticles() {
        for _ in 0..<emissionCount {
            let angle = CGFloat.random(in: 0..<(.pi * 2))
            let speed = CGFloat.random(in: 100...300)
            
            let particle = ConfettiParticle(
                position: CGPoint(x: 100, y: 100),
                velocity: CGSize(
                    width: cos(angle) * speed,
                    height: sin(angle) * speed
                ),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0),
                opacity: 1.0,
                lifetime: Double.random(in: 0.5...2.0)
            )
            
            particles.append(particle)
        }
    }
    
    private func startDisplayLink() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateParticles)
        )
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateParticles() {
        for i in particles.indices {
            particles[i].update(deltaTime: 1.0 / 60.0)
        }
        particles.removeAll { $0.opacity <= 0 }
    }
}

struct GestureRecognitionView: View {
    @State private var lastGestureType: String = "None"
    @State private var tapCount = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text(lastGestureType)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Попытайте жесты")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 200, height: 200)
                .background(Color(white: 0.12))
                .cornerRadius(12)
                .gesture(
                    SimultaneousGesture(
                        TapGesture(count: 1).onEnded {
                            lastGestureType = "Single Tap"
                        },
                        TapGesture(count: 2).onEnded {
                            lastGestureType = "Double Tap"
                        }
                    )
                )
                .gesture(
                    LongPressGesture().onEnded { _ in
                        lastGestureType = "Long Press"
                    }
                )
                .gesture(
                    DragGesture().onChanged { _ in
                        lastGestureType = "Drag"
                    }
                )
                .gesture(
                    RotationGesture().onChanged { _ in
                        lastGestureType = "Rotation"
                    }
                )
                .gesture(
                    MagnificationGesture().onChanged { _ in
                        lastGestureType = "Magnification"
                    }
                )
        }
    }
}

class PropertyAnimator: ObservableObject {
    @Published var animatedValue: CGFloat = 0
    private var displayLink: CADisplayLink?
    private var startValue: CGFloat = 0
    private var endValue: CGFloat = 0
    private var duration: TimeInterval = 0
    private var startTime: TimeInterval = 0
    
    func animateTo(value: CGFloat, duration: TimeInterval) {
        startValue = animatedValue
        endValue = value
        self.duration = duration
        startTime = CACurrentMediaTime()
        
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(update)
        )
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func update() {
        let elapsed = CACurrentMediaTime() - startTime
        let progress = min(1.0, elapsed / duration)
        
        animatedValue = startValue + (endValue - startValue) * CGFloat(progress)
        
        if progress >= 1.0 {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}

struct ParallaxScrollView<Content: View>: View {
    let content: () -> Content
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                content()
                    .offset(y: offset * 0.5)
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct HapticFeedbackGenerator {
    static func trigger(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

struct TextEffectsView: View {
    @State private var text = "Гемини"
    @State private var highlightedIndex = 0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(
                        index == highlightedIndex ? 
                        Color(red: 0.0, green: 0.4, blue: 0.8) : 
                        .white
                    )
                    .scaleEffect(index == highlightedIndex ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: highlightedIndex)
            }
        }
        .onAppear {
            startTextAnimation()
        }
    }
    
    private func startTextAnimation() {
        var index = 0
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            highlightedIndex = index % text.count
            index += 1
        }
    }
}

struct BlurredBackgroundView: View {
    let blurStyle: UIBlurEffect.Style
    
    var body: some View {
        ZStack {
            BlurView(style: blurStyle)
                .ignoresSafeArea()
            
            VStack {
                Text("Размытый фон")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct GradientAnimationView: View {
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.2, blue: 0.0),
                    Color(red: 0.2, green: 0.4, blue: 0.9)
                ]),
                startPoint: gradientStart,
                endPoint: gradientEnd
            )
            .ignoresSafeArea()
            
            Text("Анимированный градиент")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                gradientStart = .bottomTrailing
                gradientEnd = .topLeading
            }
        }
    }
}

class PerformanceOptimizer {
    static let shared = PerformanceOptimizer()
    
    private var operationQueue = OperationQueue()
    
    func executeOnBackground(_ block: @escaping () -> Void) {
        operationQueue.addOperation {
            block()
        }
    }
    
    func executeOnMainThread(_ block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    func debounce(delay: TimeInterval, action: @escaping () -> Void) {
        var workItem: DispatchWorkItem?
        
        return {
            workItem?.cancel()
            workItem = DispatchWorkItem {
                action()
            }
            
            if let workItem = workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
            }
        }() as Void
    }
    
    func throttle(delay: TimeInterval, action: @escaping () -> Void) {
        var lastExecution = Date.distantPast
        
        return {
            if Date().timeIntervalSince(lastExecution) >= delay {
                lastExecution = Date()
                action()
            }
        }() as Void
    }
}
