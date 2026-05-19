import SwiftUI

struct ToolsMenu: View {
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            ForEach(viewModel.horizontalTools) { tool in
                                ToolIconButton(tool: tool) {
                                    onDismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    }

                    Divider()
                        .background(Color(white: 0.3))
                        .padding(.horizontal, 20)

                    VStack(spacing: 0) {
                        ForEach(viewModel.verticalTools) { tool in
                            VerticalToolRow(tool: tool)

                            if tool.id != viewModel.verticalTools.last?.id {
                                Divider()
                                    .background(Color(white: 0.2))
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct ToolIconButton: View {
    let tool: ToolItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.18))
                        .frame(width: 52, height: 52)

                    Image(systemName: tool.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                Text(tool.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct VerticalToolRow: View {
    let tool: ToolItem

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: tool.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 28)

                Text(tool.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                if let badge = tool.badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.9, green: 0.3, blue: 0.4))
                        )
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    ToolsMenu(viewModel: GeminiViewModel(), onDismiss: {})
        .background(Color(red: 0.05, green: 0.05, blue: 0.08))
}