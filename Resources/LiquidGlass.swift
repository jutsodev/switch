import SwiftUI

struct LiquidGlassView: View {
    @State private var isAnimating = false
    let blurRadius: CGFloat = 20
    let glassOpacity: Double = 0.1
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Switch")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.5), radius: 20)
            }
            
            LiquidGlassBlur(
                isAnimating: $isAnimating,
                blurRadius: blurRadius,
                glassOpacity: glassOpacity
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct LiquidGlassBlur: View {
    @Binding var isAnimating: Bool
    let blurRadius: CGFloat
    let glassOpacity: Double
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            
            let waveAmplitude: CGFloat = 30 * (isAnimating ? 1.2 : 0.8)
            let waveFrequency: CGFloat = 0.02
            
            path.move(to: CGPoint(x: 0, y: size.height * 0.3))
            
            for x in stride(from: 0, to: size.width, by: 1) {
                let y = size.height * 0.3 + sin(x * waveFrequency + (isAnimating ? 2 : 0)) * waveAmplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
            
            let gradient = Gradient(colors: [
                Color(red: 0.2, green: 0.8, blue: 1.0).opacity(glassOpacity * 0.5),
                Color(red: 0.9, green: 0.3, blue: 0.8).opacity(glassOpacity * 0.3),
                Color(red: 0.5, green: 1.0, blue: 0.8).opacity(glassOpacity * 0.5)
            ])
            
            let fillStyle = FillStyle(eoFill: false, antialiased: true)
            context.fill(path, with: .linearGradient(gradient, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: size.width, y: size.height)), style: fillStyle)
            
            context.stroke(path, with: .color(Color.white.opacity(0.1)), lineWidth: 2)
        }
        .blur(radius: blurRadius * 0.5)
        .allowsHitTesting(false)
    }
}

struct GlassMorphicCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var backgroundColor: Color = Color(red: 0.1, green: 0.1, blue: 0.15)
    var blurRadius: CGFloat = 20
    var cornerRadius: CGFloat = 20
    
    var body: some View {
        ZStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        backgroundColor.opacity(0.4),
                        backgroundColor.opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .blur(radius: blurRadius * 0.3)
            
            content()
        }
    }
}

struct LiquidButtonStyle: ButtonStyle {
    @State private var isPressed = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            GlassMorphicCard(
                backgroundColor: Color(red: 0.2, green: 0.8, blue: 1.0),
                blurRadius: 15,
                cornerRadius: 12
            ) {
                EmptyView()
            }
            
            configuration.label
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .opacity(configuration.isPressed ? 0.8 : 1.0)
        .shadow(color: Color(red: 0.2, green: 0.8, blue: 1.0).opacity(configuration.isPressed ? 0.8 : 0.5), radius: 12)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct LiquidTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String?
    @State private var isFocused = false
    @FocusState private var focusState: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
            }
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.5))
                }
                .foregroundColor(.white)
                .font(.system(size: 16))
                .focused($focusState)
                .onChange(of: focusState) { newValue in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isFocused = newValue
                    }
                }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            ZStack {
                GlassMorphicCard(
                    backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                    blurRadius: isFocused ? 25 : 15,
                    cornerRadius: 12
                ) {
                    EmptyView()
                }
                
                if isFocused {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 1.0),
                                    Color(red: 0.5, green: 1.0, blue: 0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            }
        )
    }
}

struct AnimatedGlassBackground: View {
    @State private var animate = false
    
    var body: some View {
        Canvas { context, size in
            var path = Path()
            
            let speed = animate ? 1.0 : 0.0
            
            for i in stride(from: 0, to: Int(size.width), by: 40) {
                let x = CGFloat(i)
                let y = size.height * 0.2 + sin((x + size.width * speed) * 0.01) * 20
                
                let circle = Path(ellipseIn: CGRect(x: x - 20, y: y - 20, width: 40, height: 40))
                
                let gradient = Gradient(colors: [
                    Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.3),
                    Color(red: 0.9, green: 0.3, blue: 0.8).opacity(0.1)
                ])
                
                context.fill(
                    circle,
                    with: .linearGradient(
                        gradient,
                        startPoint: CGPoint(x: x, y: y),
                        endPoint: CGPoint(x: x + 40, y: y + 40)
                    )
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

struct GlassToggle: View {
    @Binding var isOn: Bool
    let label: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(
                        isOn ?
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.8, blue: 1.0),
                                Color(red: 0.5, green: 1.0, blue: 0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.2),
                                Color(white: 0.15)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 50, height: 28)
                
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 24, height: 24)
                    .padding(2)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .padding(12)
        .background(
            GlassMorphicCard(
                backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                blurRadius: 15,
                cornerRadius: 10
            ) {
                EmptyView()
            }
        )
    }
}

struct LiquidProgressBar: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(white: 0.1),
                                    Color(white: 0.05)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 1.0),
                                    Color(red: 0.5, green: 1.0, blue: 0.8)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * animatedProgress)
                        .shadow(color: Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.6), radius: 10)
                    
                    Text(String(format: "%.0f%%", animatedProgress * 100))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 20)
            }
            .frame(height: 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = newValue
            }
        }
    }
}

struct FloatingParticleView: View {
    @State private var particles: [Particle] = []
    @State private var displayLink: CADisplayLink?
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var opacity: Double
        var scale: CGFloat
    }
    
    var body: some View {
        Canvas { context, size in
            for particle in particles {
                var path = Path(ellipseIn: CGRect(
                    x: particle.x - 5 * particle.scale,
                    y: particle.y - 5 * particle.scale,
                    width: 10 * particle.scale,
                    height: 10 * particle.scale
                ))
                
                context.fill(
                    path,
                    with: .color(Color(red: 0.2, green: 0.8, blue: 1.0).opacity(particle.opacity))
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            generateParticles()
            startAnimation()
        }
    }
    
    private func generateParticles() {
        for _ in 0..<20 {
            particles.append(Particle(
                x: CGFloat.random(in: 0...400),
                y: CGFloat.random(in: 0...800),
                vx: CGFloat.random(in: -2...2),
                vy: CGFloat.random(in: -2...2),
                opacity: Double.random(in: 0.3...0.8),
                scale: CGFloat.random(in: 0.5...1.5)
            ))
        }
    }
    
    private func startAnimation() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateParticles)
        )
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateParticles() {
        for i in particles.indices {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += 0.1
            particles[i].opacity -= 0.005
            
            if particles[i].y > 900 || particles[i].opacity <= 0 {
                particles[i].x = CGFloat.random(in: 0...400)
                particles[i].y = 0
                particles[i].vy = CGFloat.random(in: -2...0)
                particles[i].opacity = Double.random(in: 0.3...0.8)
            }
        }
    }
}
