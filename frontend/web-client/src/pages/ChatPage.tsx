import { useEffect, useRef, useState } from "react";
import { useAuth } from "../context/AuthContext";
import { useChat } from "../context/ChatContext";
import ConversationItem from "../components/chat/ConversationItem";
import MessageBubble from "../components/chat/MessageBubble";
import UserSearchModal from "../components/chat/UserSearchModal";
import type { User } from "../types";

export default function ChatPage() {
  const { user } = useAuth();
  const {
    conversations,
    currentConversation,
    messages,
    connected,
    loadConversations,
    selectConversation,
    sendMessage,
    startConversation,
  } = useChat();
  const [input, setInput] = useState("");
  const [showUserSearch, setShowUserSearch] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadConversations();
  }, [loadConversations]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;
    sendMessage(input.trim());
    setInput("");
  };

  const handleStartNew = async (selectedUser: User) => {
    if (!user) return;
    const conv = await startConversation([user.id, selectedUser.id]);
    await selectConversation(conv);
  };

  if (!user) return null;

  return (
    <div className="mx-auto flex h-[calc(100vh-64px)] max-w-7xl">
      {/* Sidebar */}
      <div className="flex w-80 flex-shrink-0 flex-col border-r border-gray-200 bg-white">
        <div className="flex items-center justify-between border-b border-gray-200 p-4">
          <h2 className="text-lg font-semibold text-gray-900">Messages</h2>
          <div className="flex items-center gap-2">
            <span
              className={`h-2 w-2 rounded-full ${connected ? "bg-green-500" : "bg-red-400"}`}
            />
            <button
              onClick={() => setShowUserSearch(true)}
              className="rounded-lg bg-primary-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-primary-700"
            >
              + New
            </button>
          </div>
        </div>
        <div className="flex-1 overflow-y-auto p-2">
          {conversations.length === 0 ? (
            <p className="p-4 text-center text-sm text-gray-500">
              No conversations yet
            </p>
          ) : (
            conversations.map((conv) => (
              <ConversationItem
                key={conv.id}
                conversation={conv}
                currentUserId={user.id}
                selected={currentConversation?.id === conv.id}
                onClick={() => selectConversation(conv)}
              />
            ))
          )}
        </div>
      </div>

      {/* Chat Area */}
      <div className="flex flex-1 flex-col bg-gray-50">
        {currentConversation ? (
          <>
            {/* Chat Header */}
            <div className="border-b border-gray-200 bg-white px-6 py-4">
              <h3 className="font-semibold text-gray-900">
                {currentConversation.participantNames
                  .filter(
                    (_, i) => currentConversation.participants[i] !== user.id,
                  )
                  .join(", ") || "Chat"}
              </h3>
            </div>

            {/* Messages */}
            <div className="flex-1 overflow-y-auto px-6 py-4">
              <div className="space-y-3">
                {messages.map((msg) => (
                  <MessageBubble
                    key={msg.id}
                    message={msg}
                    isOwn={msg.senderId === user.id}
                  />
                ))}
                <div ref={messagesEndRef} />
              </div>
            </div>

            {/* Input */}
            <div className="border-t border-gray-200 bg-white p-4">
              <form onSubmit={handleSend} className="flex gap-3">
                <input
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  placeholder="Type a message..."
                  className="flex-1 rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  autoFocus
                />
                <button
                  type="submit"
                  disabled={!input.trim() || !connected}
                  className="rounded-lg bg-primary-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-50"
                >
                  Send
                </button>
              </form>
            </div>
          </>
        ) : (
          <div className="flex flex-1 items-center justify-center">
            <div className="text-center">
              <svg
                className="mx-auto h-16 w-16 text-gray-300"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={1}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                />
              </svg>
              <h3 className="mt-4 text-lg font-medium text-gray-900">
                Your Messages
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                Select a conversation or start a new one
              </p>
            </div>
          </div>
        )}
      </div>

      <UserSearchModal
        open={showUserSearch}
        onClose={() => setShowUserSearch(false)}
        onSelectUser={handleStartNew}
        title="Start New Conversation"
      />
    </div>
  );
}
