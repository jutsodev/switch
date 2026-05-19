import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var store: ConversationStore
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                header
                searchPill
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(groupedConversations(), id: \.0) { section, items in
                            sectionHeader(section)
                            ForEach(items) { conversation in
                                row(for: conversation)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 24)
                }

                footer
            }
            .frame(maxWidth: 320)
            .padding(.top, 60)
            .background(
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .ignoresSafeArea()
            )
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 0.5)
                    .frame(maxHeight: .infinity, alignment: .trailing)
            )

            Spacer(minLength: 0)
        }
    }

    private var header: some View {
        HStack {
            Text("Чаты")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            GlassIconButton(systemImage: "square.and.pencil", size: 36, fontSize: 15) {
                vm.startNewConversation()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var searchPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.55))
            Text("Поиск")
                .foregroundColor(.white.opacity(0.55))
            Spacer()
        }
        .font(.system(size: 14))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlassPill(intensity: 0.6)
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.leading, 4)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private func row(for conversation: Conversation) -> some View {
        let isActive = store.activeConversationID == conversation.id
        return Button {
            vm.switchTo(conversation.id)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: conversation.isPinned ? "pin.fill" : "bubble.left.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text(conversation.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(conversation.preview)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
                Spacer()
                Text(conversation.humanRelativeDate)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.13) : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isActive ? Color.white.opacity(0.25) : Color.clear, lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button { store.togglePinned(conversation.id) } label: {
                Label(conversation.isPinned ? "Открепить" : "Закрепить",
                      systemImage: conversation.isPinned ? "pin.slash" : "pin")
            }
            Button(role: .destructive) { store.delete(conversation.id) } label: {
                Label("Удалить", systemImage: "trash")
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Divider().overlay(Color.white.opacity(0.1))
                .padding(.horizontal, 14)

            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 28)
                    Text(String(settings.username.prefix(1)).uppercased())
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                Text(settings.username)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Button {
                    vm.showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white.opacity(0.65))
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    private func groupedConversations() -> [(String, [Conversation])] {
        let pinned = store.conversations.filter { $0.isPinned }
        let now = Date()
        let cal = Calendar.current

        func bucket(for date: Date) -> String {
            if cal.isDateInToday(date) { return "Сегодня" }
            if cal.isDateInYesterday(date) { return "Вчера" }
            if let weekAgo = cal.date(byAdding: .day, value: -7, to: now), date > weekAgo {
                return "Последние 7 дней"
            }
            if let monthAgo = cal.date(byAdding: .day, value: -30, to: now), date > monthAgo {
                return "Последние 30 дней"
            }
            return "Раньше"
        }

        let unpinned = store.conversations.filter { !$0.isPinned }
        let grouped = Dictionary(grouping: unpinned) { bucket(for: $0.updatedAt) }

        var output: [(String, [Conversation])] = []
        if !pinned.isEmpty {
            output.append(("Закреплённые", pinned))
        }
        let order = ["Сегодня", "Вчера", "Последние 7 дней", "Последние 30 дней", "Раньше"]
        for key in order {
            if let items = grouped[key], !items.isEmpty {
                output.append((key, items))
            }
        }
        return output
    }
}
