import SwiftUI

/// The screen visible most of the time: top bar, body (greeting OR messages),
/// and the input pill anchored to the bottom.
struct ChatView: View {
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var store: ConversationStore
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopBar()
                bodyArea
            }
            .padding(.bottom, 110) // leave room for the floating input bar

            InputBar()
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var bodyArea: some View {
        if let conv = store.activeConversation, !conv.messages.isEmpty {
            MessageListView(conversation: conv)
        } else {
            GreetingView()
        }
    }
}

private struct MessageListView: View {
    let conversation: Conversation

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(conversation.messages) { message in
                        MessageBubbleView(message: message)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 6)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: conversation.messages.count) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    if let last = conversation.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: conversation.messages.last?.content ?? "") { _ in
                if let last = conversation.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onAppear {
                if let last = conversation.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
