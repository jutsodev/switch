import SwiftUI

struct ModelSelectionMenu: View {
    @ObservedObject var viewModel: GeminiViewModel
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Text("Выберите модель")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    ForEach(viewModel.availableModels) { model in
                        ModelRow(model: model, isSelected: viewModel.selectedModel.id == model.id) {
                            viewModel.selectModel(model)
                            onDismiss()
                        }

                        if model.id != viewModel.availableModels.last?.id {
                            Divider()
                                .background(Color(white: 0.3))
                                .padding(.horizontal, 20)
                        }
                    }

                    Divider()
                        .background(Color(white: 0.3))
                        .padding(.horizontal, 20)

                    Button(action: {}) {
                        HStack {
                            Image(systemName: "brain")
                                .font(.system(size: 18))
                                .foregroundColor(.white)

                            Text("Уровень рассуждений")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)

                            Spacer()

                            Text("Средний")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }
                    .padding(.bottom, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.18))
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct ModelRow: View {
    let model: ModelOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? Color(red: 0.3, green: 0.5, blue: 1.0)
                            : Color(white: 0.25)
                        )
                        .frame(width: 36, height: 36)

                    if !isSelected {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    Text(model.subtext)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.3, green: 0.6, blue: 1.0))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    ModelSelectionMenu(viewModel: GeminiViewModel(), onDismiss: {})
        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
}