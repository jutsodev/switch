import SwiftUI
import Combine

extension View {
    func fadeIn(duration: Double = 0.3) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(.easeIn(duration: duration)) {
                    
                }
            }
    }
    
    func slideInFromLeft(duration: Double = 0.3) -> some View {
        self
            .offset(x: -100)
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    
                }
            }
    }
    
    func slideInFromRight(duration: Double = 0.3) -> some View {
        self
            .offset(x: 100)
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    
                }
            }
    }
    
    func slideInFromBottom(duration: Double = 0.3) -> some View {
        self
            .offset(y: 100)
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    
                }
            }
    }
    
    func scaleIn(duration: Double = 0.3) -> some View {
        self
            .scaleEffect(0.5)
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    
                }
            }
    }
    
    func rotateIn(duration: Double = 0.5) -> some View {
        self
            .rotationEffect(.degrees(-180))
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) {
                    
                }
            }
    }
    
    func shimmerEffect() -> some View {
        self
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        Color.white.opacity(0.2),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: -400)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: UUID())
            )
    }
    
    func pulseEffect() -> some View {
        self
            .scaleEffect(1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    
                }
            }
    }
    
    func glow(color: Color, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color, radius: radius)
            .shadow(color: color, radius: radius / 2)
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        
        let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
        let g = CGFloat((hexNumber & 0xFF00) >> 8) / 255
        let b = CGFloat(hexNumber & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    func truncated(length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        }
        return self
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidURL() -> Bool {
        let urlRegex = "^(https?://)?(www\\.)?([-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&/=]*))?$"
        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return urlPredicate.evaluate(with: self)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    func safe(_ index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}

struct AnimationModifier: ViewModifier {
    var animationType: AnimationType
    var duration: Double
    @State private var isAnimating = false
    
    enum AnimationType {
        case bounce
        case swing
        case heartbeat
        case flash
        case spin
    }
    
    func body(content: Content) -> some View {
        content
            .modifier(AnimationContent(animationType: animationType, duration: duration))
    }
}

struct AnimationContent: ViewModifier {
    var animationType: AnimationModifier.AnimationType
    var duration: Double
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        switch animationType {
        case .bounce:
            content
                .offset(y: isAnimating ? -10 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        case .swing:
            content
                .rotationEffect(.degrees(isAnimating ? 15 : -15), anchor: .top)
                .onAppear {
                    withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        case .heartbeat:
            content
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: duration * 0.5).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        case .flash:
            content
                .opacity(isAnimating ? 0.5 : 1.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
        case .spin:
            content
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .onAppear {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        isAnimating = true
                    }
                }
        }
    }
}

extension View {
    func animate(type: AnimationModifier.AnimationType, duration: Double = 1.0) -> some View {
        self.modifier(AnimationModifier(animationType: type, duration: duration))
    }
}

class DebugLogger {
    static let shared = DebugLogger()
    
    private var logs: [String] = []
    
    func log(_ message: String, level: LogLevel = .info) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let logMessage = "[\(timestamp)] [\(level.rawValue)] \(message)"
        logs.append(logMessage)
        print(logMessage)
    }
    
    func getLogs() -> [String] {
        return logs
    }
    
    func clearLogs() {
        logs.removeAll()
    }
    
    func saveLogs(to url: URL) -> Bool {
        let content = logs.joined(separator: "\n")
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Failed to save logs: \(error)")
            return false
        }
    }
}

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

struct ResponsiveView<Content: View>: View {
    let content: (GeometryProxy) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            content(geometry)
        }
    }
}

class MemoryMonitor: ObservableObject {
    @Published var memoryUsage: Double = 0
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.updateMemoryUsage()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateMemoryUsage() {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size/4)
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(
                    mach_task_self_,
                    task_flavor_t(TASK_VM_INFO),
                    $0,
                    &count
                )
            }
        }
        
        if result == KERN_SUCCESS {
            let memoryUsageInBytes = Double(info.phys_footprint)
            let memoryUsageInMB = memoryUsageInBytes / (1024 * 1024)
            self.memoryUsage = memoryUsageInMB
        }
    }
    
    deinit {
        stop()
    }
}

struct PerformanceMonitor: View {
    @StateObject private var memoryMonitor = MemoryMonitor()
    @State private var fps: Double = 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Производительность")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Память")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(String(format: "%.1f MB", memoryMonitor.memoryUsage))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("FPS")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(String(format: "%.0f", fps))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(8)
            .background(Color(white: 0.12))
            .cornerRadius(6)
        }
        .onAppear {
            memoryMonitor.start()
        }
        .onDisappear {
            memoryMonitor.stop()
        }
    }
}

class ThemeManager: ObservableObject {
    @Published var isDarkMode = true
    @Published var primaryColor = Color(red: 0.0, green: 0.4, blue: 0.8)
    @Published var secondaryColor = Color(red: 0.8, green: 0.2, blue: 0.0)
    
    static let shared = ThemeManager()
    
    func applyTheme(_ theme: AppTheme) {
        isDarkMode = theme.isDarkMode
        primaryColor = theme.primaryColor
        secondaryColor = theme.secondaryColor
    }
}

struct AppTheme {
    let name: String
    let isDarkMode: Bool
    let primaryColor: Color
    let secondaryColor: Color
    
    static let default = AppTheme(
        name: "Default",
        isDarkMode: true,
        primaryColor: Color(red: 0.0, green: 0.4, blue: 0.8),
        secondaryColor: Color(red: 0.8, green: 0.2, blue: 0.0)
    )
    
    static let ocean = AppTheme(
        name: "Ocean",
        isDarkMode: true,
        primaryColor: Color(red: 0.0, green: 0.6, blue: 0.9),
        secondaryColor: Color(red: 0.0, green: 0.8, blue: 1.0)
    )
    
    static let sunset = AppTheme(
        name: "Sunset",
        isDarkMode: true,
        primaryColor: Color(red: 1.0, green: 0.6, blue: 0.2),
        secondaryColor: Color(red: 1.0, green: 0.3, blue: 0.1)
    )
}

extension View {
    @ViewBuilder
    func debugBorder() -> some View {
        #if DEBUG
        self.border(Color.red)
        #else
        self
        #endif
    }
}
