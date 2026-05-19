import SwiftUI

struct FloatingInputField: View {
    @ObservedObject var viewModel: GeminiViewModel
    @FocusState private var isFocused: Bool
    let onToolsTap: () -> Void

    private var isExpanded: Bool {
        viewModel.inputState == .expanded
    }

    var body: some View {
        HStack(spacing: 12) {
            if isExpanded {
                filePreviewStrip
            }

            if !isExpanded {
                Button(action: onToolsTap) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                }
            }

            textField

            if isExpanded {
                sendButton
            } else {
                micButton
                speakerButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(white: 0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color(white: 0.25), lineWidth: 0.5)
        )
        .scaleEffect(isExpanded ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .onTapGesture {
            if !isExpanded {
                viewModel.expandInput()
            }
        }
    }

    private var textField: some View {
        TextField("Спросите Gemini", text: $viewModel.inputText)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.white)
            .focused($isFocused)
            .onChange(of: isFocused) { _, newValue in
                if newValue && viewModel.inputState == .collapsed {
                    viewModel.expandInput()
                }
            }
    }

    private var sendButton: some View {
        Button(action: {
            viewModel.sendMessage()
            isFocused = false
        }) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(
                    viewModel.inputText.isEmpty && !viewModel.hasAttachedFiles
                    ? .gray
                    : Color(red: 0.4, green: 0.6, blue: 1.0)
                )
        }
        .disabled(viewModel.inputText.isEmpty && !viewModel.hasAttachedFiles)
    }

    private var micButton: some View {
        Button(action: {}) {
            Image(systemName: "mic")
                .font(.system(size: 20))
                .foregroundColor(.gray)
        }
    }

    private var speakerButton: some View {
        Button(action: {}) {
            Image(systemName: "speaker.wave.3")
                .font(.system(size: 20))
                .foregroundColor(.gray)
        }
    }

    private var filePreviewStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.attachedFiles) { file in
                    FilePreviewCircle(file: file) {
                        viewModel.removeFile(file)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.08)
        VStack {
            Spacer()
            FloatingInputField(viewModel: GeminiViewModel(), onToolsTap: {})
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
        }
    }
}