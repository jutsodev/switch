import SwiftUI

struct InputFieldView: View {
    @ObservedObject var viewModel: GeminiUIViewModel
    @FocusState private var isInputFocused: Bool
    @State private var inputHeight: CGFloat = 44
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if !viewModel.selectedFiles.isEmpty {
                    AttachedFilesScrollView(files: viewModel.selectedFiles, viewModel: viewModel)
                        .frame(height: 100)
                        .padding(.bottom, 12)
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.toggleToolsMenu()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                    }
                    
                    TextField("", text: $viewModel.currentInputText)
                        .placeholder(when: viewModel.currentInputText.isEmpty) {
                            Text("Спросите Gemini")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(height: 36)
                        .padding(.horizontal, 12)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                        .focused($isInputFocused)
                    
                    if !viewModel.isRecordingAudio {
                        Button(action: {
                            viewModel.startAudioRecording()
                        }) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color(white: 0.15))
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            viewModel.stopAudioRecording()
                        }) {
                            Image(systemName: "mic.slash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                                .frame(width: 36, height: 36)
                                .background(Color(white: 0.15))
                                .cornerRadius(8)
                        }
                    }
                    
                    if viewModel.currentInputText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button(action: {}) {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color(white: 0.15))
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                                .frame(width: 36, height: 36)
                        }
                    }
                }
                .padding(12)
                .background(Color(white: 0.09))
                .cornerRadius(12)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .background(Color("backgroundColor"))
        }
    }
}

struct AttachedFilesScrollView: View {
    let files: [AttachedFile]
    @ObservedObject var viewModel: GeminiUIViewModel
    @StateObject private var fileRemovalService = FileRemovalService()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(files) { file in
                    FilePreviewCircleView(
                        file: file,
                        viewModel: viewModel,
                        fileRemovalService: fileRemovalService
                    )
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

struct FilePreviewCircleView: View {
    let file: AttachedFile
    @ObservedObject var viewModel: GeminiUIViewModel
    @ObservedObject var fileRemovalService: FileRemovalService
    
    @State private var showLiquidation = false
    @State private var liquidationScale: CGFloat = 0.3
    @State private var liquidationOpacity: Double = 0
    @State private var blurAmount: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.8, green: 0.2, blue: 0.0),
                                Color(red: 0.2, green: 0.4, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    HStack(spacing: 0) {
                        if file.type == .image {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        } else if file.type == .document {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        } else if file.type == .text {
                            Image(systemName: "text.document.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        } else if file.type == .audio {
                            Image(systemName: "waveform")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "square.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    Button(action: {
                        initiateEyeLiquidation()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(white: 0.1))
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 28, height: 28)
                            )
                    }
                    .offset(x: 8, y: -8)
                }
                
                Text(file.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
            
            if showLiquidation {
                EyeLiquidationOverlayView(
                    scale: $liquidationScale,
                    opacity: $liquidationOpacity,
                    blurAmount: $blurAmount,
                    onComplete: {
                        showLiquidation = false
                        viewModel.removeFile(file.id)
                    }
                )
            }
        }
        .opacity(fileRemovalService.activeRemovals.contains(file.id) ? 0 : 1)
    }
    
    private func initiateEyeLiquidation() {
        showLiquidation = true
        fileRemovalService.queueFileForRemoval(file.id)
        
        withAnimation(.easeIn(duration: 0.15)) {
            liquidationScale = 1.0
            liquidationOpacity = 1.0
            blurAmount = 8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.1)) {
                blurAmount = 5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    liquidationScale = 0.1
                    liquidationOpacity = 0
                    blurAmount = 0
                }
            }
        }
    }
}

struct EyeLiquidationOverlayView: View {
    @Binding var scale: CGFloat
    @Binding var opacity: Double
    @Binding var blurAmount: CGFloat
    let onComplete: () -> Void
    
    @State private var eyeOpacity: Double = 0
    @State private var eyeScale: CGFloat = 0.5
    @State private var particleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.8, green: 0.2, blue: 0.0),
                        Color(red: 0.2, green: 0.4, blue: 0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .scaleEffect(scale)
                .blur(radius: blurAmount)
                .opacity(opacity)
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .fill(Color.black)
                    .frame(width: 30, height: 30)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: -5, y: -5)
            }
            .scaleEffect(eyeScale)
            .opacity(eyeOpacity)
            
            ForEach(0..<8, id: \.self) { index in
                let angle: Double = Double(index) * (360.0 / 8.0)
                let radians = angle * .pi / 180.0
                
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.2, blue: 0.0).opacity(0.6),
                            Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.6)
                        ]),
                        startPoint: .center,
                        endPoint: .topTrailing
                    ))
                    .frame(width: 4, height: 4)
                    .offset(x: cos(radians) * 80, y: sin(radians) * 80)
                    .opacity(particleOpacity)
            }
        }
        .frame(width: 180, height: 180)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2).delay(0.1)) {
                eyeOpacity = 1
                eyeScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                particleOpacity = 0
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    ZStack {
        Color("backgroundColor").ignoresSafeArea()
        
        VStack {
            Spacer()
            
            InputFieldView(viewModel: GeminiUIViewModel())
        }
    }
}
