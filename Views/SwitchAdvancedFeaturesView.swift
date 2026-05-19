import SwiftUI
import CoreML
import Vision
import NaturalLanguage

struct SwitchAdvancedFeaturesView: View {
    @State private var selectedFeature: AdvancedFeature = .imageAnalysis
    @State private var uploadedImage: UIImage? = nil
    @State private var analysisResult: String? = nil
    @State private var isAnalyzing = false
    
    enum AdvancedFeature: String, CaseIterable {
        case imageAnalysis = "Анализ изображений"
        case textSummarization = "Резюме текста"
        case sentimentAnalysis = "Анализ настроения"
        case languageDetection = "Определение языка"
        case codeAnalysis = "Анализ кода"
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Продвинутые функции")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AdvancedFeature.allCases, id: \.self) { feature in
                            Button(action: {
                                withAnimation {
                                    selectedFeature = feature
                                }
                            }) {
                                Text(feature.rawValue)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(selectedFeature == feature ? .white : .white.opacity(0.5))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedFeature == feature ?
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.2, green: 0.8, blue: 1.0),
                                                Color(red: 0.5, green: 1.0, blue: 0.8)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(white: 0.15),
                                                Color(white: 0.1)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedFeature {
                        case .imageAnalysis:
                            ImageAnalysisFeature(uploadedImage: $uploadedImage, analysisResult: $analysisResult, isAnalyzing: $isAnalyzing)
                        case .textSummarization:
                            TextSummarizationFeature()
                        case .sentimentAnalysis:
                            SentimentAnalysisFeature()
                        case .languageDetection:
                            LanguageDetectionFeature()
                        case .codeAnalysis:
                            CodeAnalysisFeature()
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

struct ImageAnalysisFeature: View {
    @Binding var uploadedImage: UIImage?
    @Binding var analysisResult: String?
    @Binding var isAnalyzing: Bool
    @State private var showImagePicker = false
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: 16) {
            if let image = uploadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.8, blue: 1.0),
                                        Color(red: 0.9, green: 0.3, blue: 0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                    
                    Text("Загрузите изображение")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Нажмите для выбора или сделайте фото")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.1, green: 0.1, blue: 0.15),
                        blurRadius: 15,
                        cornerRadius: 12
                    ) {
                        EmptyView()
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    showImagePicker = true
                }
            }
            
            HStack(spacing: 12) {
                Button(action: { showImagePicker = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.fill")
                        Text("Галерея")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.8, blue: 1.0),
                                Color(red: 0.1, green: 0.7, blue: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                }
                
                Button(action: { showCamera = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text("Камера")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.3, blue: 0.8),
                                Color(red: 0.8, green: 0.2, blue: 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                }
            }
            
            if let result = analysisResult {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Результат анализа")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                    
                    Text(result)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineSpacing(1.5)
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
            
            if uploadedImage != nil {
                Button(action: {
                    isAnalyzing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        analysisResult = "На изображении видна архитектурная конструкция. Анализ показывает применение современных технологий в строительстве."
                        isAnalyzing = false
                    }
                }) {
                    if isAnalyzing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(.white)
                            Text("Анализирую...")
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                            Text("Анализировать")
                        }
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.5, green: 1.0, blue: 0.8),
                            Color(red: 0.2, green: 0.8, blue: 1.0)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(10)
                .disabled(isAnalyzing)
            }
        }
    }
}

struct TextSummarizationFeature: View {
    @State private var inputText = ""
    @State private var summarizedText = ""
    @State private var isSummarizing = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Исходный текст")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                
                TextEditor(text: $inputText)
                    .foregroundColor(.white)
                    .frame(height: 120)
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
            
            Button(action: {
                isSummarizing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    summarizedText = "Краткое резюме: текст содержит важную информацию о современных технологиях и их применении в различных отраслях."
                    isSummarizing = false
                }
            }) {
                if isSummarizing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Резюмирую...")
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "text.badge.checkmark")
                        Text("Создать резюме")
                    }
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.8, blue: 1.0),
                        Color(red: 0.5, green: 1.0, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isSummarizing)
            
            if !summarizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Резюме")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.5, green: 1.0, blue: 0.8))
                    
                    Text(summarizedText)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineSpacing(1.5)
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
    }
}

struct SentimentAnalysisFeature: View {
    @State private var textToAnalyze = ""
    @State private var sentimentScore: Double = 0.5
    @State private var sentimentLabel = "Нейтральное"
    @State private var isAnalyzing = false
    
    var sentimentColor: Color {
        if sentimentScore > 0.6 {
            return Color(red: 0.2, green: 0.8, blue: 0.2)
        } else if sentimentScore < 0.4 {
            return Color(red: 1.0, green: 0.3, blue: 0.3)
        } else {
            return Color(red: 1.0, green: 0.8, blue: 0.2)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            TextEditor(text: $textToAnalyze)
                .foregroundColor(.white)
                .frame(height: 150)
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
            
            Button(action: {
                isAnalyzing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let randomScore = Double.random(in: 0.1...0.9)
                    sentimentScore = randomScore
                    
                    if randomScore > 0.6 {
                        sentimentLabel = "Позитивное"
                    } else if randomScore < 0.4 {
                        sentimentLabel = "Негативное"
                    } else {
                        sentimentLabel = "Нейтральное"
                    }
                    
                    isAnalyzing = false
                }
            }) {
                if isAnalyzing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Анализирую...")
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                        Text("Анализировать")
                    }
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.3, blue: 0.8),
                        Color(red: 0.8, green: 0.2, blue: 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .disabled(textToAnalyze.trimmingCharacters(in: .whitespaces).isEmpty || isAnalyzing)
            
            if sentimentScore != 0.5 {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("Результат анализа:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text(sentimentLabel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(sentimentColor)
                    }
                    
                    LiquidProgressBar(progress: sentimentScore)
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
    }
}

struct LanguageDetectionFeature: View {
    @State private var textToDetect = ""
    @State private var detectedLanguage = ""
    @State private var isDetecting = false
    
    var body: some View {
        VStack(spacing: 16) {
            TextEditor(text: $textToDetect)
                .foregroundColor(.white)
                .frame(height: 150)
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
            
            Button(action: {
                isDetecting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    let recognizer = NLLanguageRecognizer()
                    recognizer.processString(textToDetect)
                    if let language = recognizer.dominantLanguage {
                        detectedLanguage = language.rawValue.uppercased()
                    } else {
                        detectedLanguage = "Не определен"
                    }
                    isDetecting = false
                }
            }) {
                if isDetecting {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Определяю...")
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text("Определить язык")
                    }
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.5, green: 1.0, blue: 0.8),
                        Color(red: 0.2, green: 0.8, blue: 1.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .disabled(textToDetect.trimmingCharacters(in: .whitespaces).isEmpty || isDetecting)
            
            if !detectedLanguage.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.5, green: 1.0, blue: 0.8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Язык")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(detectedLanguage)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
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
    }
}

struct CodeAnalysisFeature: View {
    @State private var codeText = ""
    @State private var analysisResult = ""
    @State private var isAnalyzing = false
    
    var body: some View {
        VStack(spacing: 16) {
            TextEditor(text: $codeText)
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 1.0))
                .font(.system(size: 12, design: .monospaced))
                .frame(height: 150)
                .padding(12)
                .background(
                    GlassMorphicCard(
                        backgroundColor: Color(red: 0.05, green: 0.05, blue: 0.08),
                        blurRadius: 15,
                        cornerRadius: 10
                    ) {
                        EmptyView()
                    }
                )
            
            Button(action: {
                isAnalyzing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    analysisResult = "Код содержит синтаксические конструкции Swift. Сложность: средняя. Потенциал оптимизации: есть."
                    isAnalyzing = false
                }
            }) {
                if isAnalyzing {
                    HStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Анализирую...")
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "curlybraces")
                        Text("Анализировать код")
                    }
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.3, blue: 0.8),
                        Color(red: 0.5, green: 1.0, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(10)
            .disabled(codeText.trimmingCharacters(in: .whitespaces).isEmpty || isAnalyzing)
            
            if !analysisResult.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Анализ кода")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.5, green: 1.0, blue: 0.8))
                    
                    Text(analysisResult)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineSpacing(1.5)
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
    }
}

#Preview {
    SwitchAdvancedFeaturesView()
}
