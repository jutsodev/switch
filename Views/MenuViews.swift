import SwiftUI

struct ModelSelectionMenuView: View {
    @ObservedObject var viewModel: GeminiUIViewModel
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Выберите модель")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Divider()
                        .background(Color(white: 0.2))
                    
                    VStack(spacing: 8) {
                        ModelSelectionItemView(
                            model: GeminiModel(
                                id: "gemini-2.0-flash-lite",
                                name: "Gemini 2.0 Flash Lite",
                                description: "Легкая и быстрая модель для базовых задач",
                                tier: .flashLite,
                                releaseDate: Date(),
                                maxTokens: 100000,
                                costPer1MInputTokens: 0.04,
                                costPer1MOutputTokens: 0.15
                            ),
                            isSelected: viewModel.uiState.selectedModel.id == "gemini-2.0-flash-lite",
                            onSelect: {
                                viewModel.selectModel(GeminiModel(
                                    id: "gemini-2.0-flash-lite",
                                    name: "Gemini 2.0 Flash Lite",
                                    description: "Легкая и быстрая модель для базовых задач",
                                    tier: .flashLite,
                                    releaseDate: Date(),
                                    maxTokens: 100000,
                                    costPer1MInputTokens: 0.04,
                                    costPer1MOutputTokens: 0.15
                                ))
                            }
                        )
                        
                        ModelSelectionItemView(
                            model: GeminiModel(
                                id: "gemini-2.0-flash",
                                name: "Gemini 2.0 Flash",
                                description: "Оптимальный баланс скорости и качества",
                                tier: .flash,
                                releaseDate: Date(),
                                maxTokens: 1000000,
                                costPer1MInputTokens: 0.075,
                                costPer1MOutputTokens: 0.3
                            ),
                            isSelected: viewModel.uiState.selectedModel.id == "gemini-2.0-flash",
                            onSelect: {
                                viewModel.selectModel(GeminiModel(
                                    id: "gemini-2.0-flash",
                                    name: "Gemini 2.0 Flash",
                                    description: "Оптимальный баланс скорости и качества",
                                    tier: .flash,
                                    releaseDate: Date(),
                                    maxTokens: 1000000,
                                    costPer1MInputTokens: 0.075,
                                    costPer1MOutputTokens: 0.3
                                ))
                            }
                        )
                        
                        ModelSelectionItemView(
                            model: GeminiModel(
                                id: "gemini-2.0-pro",
                                name: "Gemini 2.0 Pro",
                                description: "Самая мощная модель для сложных задач",
                                tier: .pro,
                                releaseDate: Date(),
                                maxTokens: 2000000,
                                costPer1MInputTokens: 0.15,
                                costPer1MOutputTokens: 0.6
                            ),
                            isSelected: viewModel.uiState.selectedModel.id == "gemini-2.0-pro",
                            onSelect: {
                                viewModel.selectModel(GeminiModel(
                                    id: "gemini-2.0-pro",
                                    name: "Gemini 2.0 Pro",
                                    description: "Самая мощная модель для сложных задач",
                                    tier: .pro,
                                    releaseDate: Date(),
                                    maxTokens: 2000000,
                                    costPer1MInputTokens: 0.15,
                                    costPer1MOutputTokens: 0.6
                                ))
                            }
                        )
                    }
                    
                    Divider()
                        .background(Color(white: 0.2))
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                        
                        Text("Уровень рассуждений")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {}
                }
                .padding(16)
                .background(Color(white: 0.09))
                .cornerRadius(16)
                .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct ModelSelectionItemView: View {
    let model: GeminiModel
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(model.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if model.tier == .flashLite {
                        Text("Lite")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(white: 0.2))
                            .cornerRadius(4)
                    }
                }
                
                Text(model.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
            } else {
                Circle()
                    .stroke(Color(white: 0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(12)
        .background(isSelected ? Color(white: 0.12) : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct ToolsMenuView: View {
    @ObservedObject var viewModel: GeminiUIViewModel
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Инструменты")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ToolIconButtonView(icon: "photo.fill", label: "Фото")
                            ToolIconButtonView(icon: "camera.fill", label: "Камера")
                            ToolIconButtonView(icon: "doc.fill", label: "Файлы")
                            ToolIconButtonView(icon: "folder.fill", label: "Диск")
                            ToolIconButtonView(icon: "note.text", label: "Блокноты")
                        }
                    }
                    
                    Divider()
                        .background(Color(white: 0.2))
                    
                    VStack(spacing: 12) {
                        ToolFeatureRowView(
                            icon: "photo.fill",
                            title: "Изображения",
                            description: "Генерировать, анализировать и редактировать изображения"
                        )
                        
                        ToolFeatureRowView(
                            icon: "music.quaver",
                            title: "Музыка",
                            description: "Создавать и исследовать музыку",
                            isNew: true
                        )
                        
                        ToolFeatureRowView(
                            icon: "square.and.pencil",
                            title: "Canvas",
                            description: "Проектировать и прототипировать интерфейсы"
                        )
                        
                        ToolFeatureRowView(
                            icon: "magnifyingglass",
                            title: "Deep Research",
                            description: "Углубленный анализ и исследование"
                        )
                        
                        ToolFeatureRowView(
                            icon: "book.fill",
                            title: "Обучение",
                            description: "Изучать новые концепции и навыки"
                        )
                    }
                }
                .padding(16)
                .background(Color(white: 0.09))
                .cornerRadius(16)
                .padding(16)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct ToolIconButtonView: View {
    let icon: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color(white: 0.15))
                .cornerRadius(12)
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

struct ToolFeatureRowView: View {
    let icon: String
    let title: String
    let description: String
    var isNew: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                .frame(width: 40, height: 40)
                .background(Color(white: 0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if isNew {
                        Text("Новинка")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.8, green: 0.2, blue: 0.0))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.8, green: 0.2, blue: 0.0).opacity(0.2))
                            .cornerRadius(3)
                    }
                }
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(12)
        .background(Color(white: 0.12))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {}
    }
}

#Preview {
    ModelSelectionMenuView(viewModel: GeminiUIViewModel())
        .environmentObject(DataStore())
}
