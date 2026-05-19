import SwiftUI

struct StatusBarView: View {
    var body: some View {
        HStack {
            Text("17:25")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: 5) {
                Image(systemName: "wifi")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)

                Image(systemName: "battery.25")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .overlay(
                        BatteryShape()
                            .stroke(Color.white, lineWidth: 1)
                            .padding(.leading, 2)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct BatteryShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect.insetBy(dx: 1, dy: 2))
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY - 3))
        path.addLine(to: CGPoint(x: rect.maxX + 3, y: rect.midY - 3))
        path.addLine(to: CGPoint(x: rect.maxX + 3, y: rect.midY + 3))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + 3))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color(red: 0.05, green: 0.05, blue: 0.08)
        StatusBarView()
    }
}