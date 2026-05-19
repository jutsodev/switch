import SwiftUI

struct FilePreviewCircle: View {
    let file: FileItem
    let onRemove: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundForType)
                .frame(width: 40, height: 40)

            if let thumbnailData = file.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: file.type.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }

            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                .frame(width: 40, height: 40)

            Button(action: onRemove) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 18, height: 18)

                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(x: 14, y: -14)
        }
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .onLongPressGesture(minimumDuration: 0.3, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }

    private var backgroundForType: Color {
        switch file.type {
        case .image:
            return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .document:
            return Color(red: 0.4, green: 0.4, blue: 0.5)
        case .audio:
            return Color(red: 0.5, green: 0.2, blue: 0.6)
        case .video:
            return Color(red: 0.6, green: 0.2, blue: 0.2)
        case .other:
            return Color(red: 0.3, green: 0.3, blue: 0.4)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        FilePreviewCircle(
            file: FileItem(name: "photo.jpg", type: .image),
            onRemove: {}
        )
        FilePreviewCircle(
            file: FileItem(name: "doc.pdf", type: .document),
            onRemove: {}
        )
        FilePreviewCircle(
            file: FileItem(name: "song.mp3", type: .audio),
            onRemove: {}
        )
    }
    .padding()
    .background(Color(red: 0.05, green: 0.05, blue: 0.08))
}