import SwiftUI

struct StatusBarView: View {
    @State private var currentTime = ""
    @State private var updateTimer: Timer?
    
    var body: some View {
        HStack(spacing: 0) {
            Text(currentTime)
                .font(.system(size: 14, weight: .semibold))
                .frame(minWidth: 40)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "wifi")
                    .font(.system(size: 10))
                
                Image(systemName: "signal.medium.fill")
                    .font(.system(size: 10))
                
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 6)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2, height: 8)
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.white)
                        .frame(width: 2, height: 10)
                }
                .frame(width: 12, height: 10)
                
                Text("15%")
                    .font(.system(size: 10))
            }
            .font(.system(size: 10))
            .foregroundColor(Color.white)
        }
        .foregroundColor(Color.white.opacity(0.9))
        .frame(height: 24)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color("backgroundColor"))
        .onAppear {
            updateTime()
            updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateTime()
            }
        }
        .onDisappear {
            updateTimer?.invalidate()
        }
    }
    
    private func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }
}

struct HeaderView: View {
    @ObservedObject var viewModel: GeminiUIViewModel
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(viewModel.uiState.selectedModel.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.toggleModelMenu()
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(Color("backgroundColor"))
    }
}

struct CentralLogoView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.8, green: 0.2, blue: 0.0),
                                Color(red: 0.2, green: 0.4, blue: 0.9),
                                Color(red: 0.8, green: 0.2, blue: 0.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Capsule()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.8, green: 0.2, blue: 0.0),
                                    Color(red: 1.0, green: 0.4, blue: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 12, height: 40)
                        
                        Spacer()
                        
                        Capsule()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.4, blue: 0.9),
                                    Color(red: 0.4, green: 0.6, blue: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 12, height: 40)
                    }
                    .frame(height: 50)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Capsule()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.8, blue: 0.2),
                                    Color(red: 0.4, green: 1.0, blue: 0.4)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 12, height: 40)
                        
                        Spacer()
                        
                        Capsule()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.2),
                                    Color(red: 1.0, green: 1.0, blue: 0.4)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: 12, height: 40)
                    }
                    .frame(height: 50)
                }
                .frame(width: 100, height: 100)
            }
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            VStack(spacing: 8) {
                Text("Привет, Дима!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Что вас интересует?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("backgroundColor"))
    }
}

struct TemporaryChatDescriptionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text("Здравствуйте!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Временные чаты не появляются в списке недавних и не используются для улучшения ИИ от Google.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Они хранятся 72 часа для обеспечения безопасности.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ZStack {
        Color("backgroundColor").ignoresSafeArea()
        
        VStack {
            StatusBarView()
            
            Spacer()
            
            CentralLogoView()
            
            Spacer()
        }
    }
}
