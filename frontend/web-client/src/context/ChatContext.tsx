import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  useRef,
  type ReactNode,
} from "react";
import { Client } from "@stomp/stompjs";
import type {
  ConversationResponse,
  MessageResponse,
  TypingIndicator,
} from "../types";
import { chatService } from "../services/chat";
import { useAuth } from "./AuthContext";
import { getToken } from "../utils/localStorage";

interface ChatContextType {
  conversations: ConversationResponse[];
  currentConversation: ConversationResponse | null;
  messages: MessageResponse[];
  connected: boolean;
  typingUsers: Map<string, string>;
  loadConversations: () => Promise<void>;
  selectConversation: (conv: ConversationResponse) => Promise<void>;
  sendMessage: (content: string) => void;
  startConversation: (
    participantIds: number[],
  ) => Promise<ConversationResponse>;
}

const ChatContext = createContext<ChatContextType | undefined>(undefined);

export function ChatProvider({ children }: { children: ReactNode }) {
  const { user, isAuthenticated } = useAuth();
  const [conversations, setConversations] = useState<ConversationResponse[]>(
    [],
  );
  const [currentConversation, setCurrentConversation] =
    useState<ConversationResponse | null>(null);
  const [messages, setMessages] = useState<MessageResponse[]>([]);
  const [connected, setConnected] = useState(false);
  const [typingUsers] = useState<Map<string, string>>(new Map());
  const clientRef = useRef<Client | null>(null);
  const subsRef = useRef<{ unsubscribe: () => void }[]>([]);

  // Connect to WebSocket
  useEffect(() => {
    if (!isAuthenticated || !user) return;

    const token = getToken();
    const stompClient = new Client({
      brokerURL: `ws://localhost:8080/ws/chat?token=${encodeURIComponent(token || "")}`,
      reconnectDelay: 5000,
      onConnect: () => {
        setConnected(true);
        // Announce online
        stompClient.publish({
          destination: "/app/chat/online",
          body: String(user.id),
        });
      },
      onDisconnect: () => setConnected(false),
      onStompError: () => setConnected(false),
    });

    stompClient.activate();
    clientRef.current = stompClient;

    return () => {
      if (stompClient.connected) {
        stompClient.publish({
          destination: "/app/chat/offline",
          body: String(user.id),
        });
      }
      stompClient.deactivate();
    };
  }, [isAuthenticated, user]);

  // Subscribe to current conversation messages
  useEffect(() => {
    const client = clientRef.current;
    if (!client || !connected || !currentConversation) return;

    // Unsubscribe previous
    subsRef.current.forEach((s) => s.unsubscribe());
    subsRef.current = [];

    const msgSub = client.subscribe(
      `/topic/messages/${currentConversation.id}`,
      (frame) => {
        const msg: MessageResponse = JSON.parse(frame.body);
        setMessages((prev) => [...prev, msg]);
      },
    );
    subsRef.current.push(msgSub);

    return () => {
      subsRef.current.forEach((s) => s.unsubscribe());
      subsRef.current = [];
    };
  }, [connected, currentConversation]);

  const loadConversations = useCallback(async () => {
    if (!isAuthenticated) return;
    const res = await chatService.getConversations();
    setConversations(res.data);
  }, [isAuthenticated]);

  const selectConversation = useCallback(async (conv: ConversationResponse) => {
    setCurrentConversation(conv);
    const res = await chatService.getMessages(conv.id);
    setMessages(res.data.content?.reverse() || []);
    await chatService.markRead(conv.id);
  }, []);

  const sendMessage = useCallback(
    (content: string) => {
      const client = clientRef.current;
      if (!client || !connected || !currentConversation) return;
      client.publish({
        destination: "/app/chat/send",
        body: JSON.stringify({
          conversationId: currentConversation.id,
          content,
        }),
      });
    },
    [connected, currentConversation],
  );

  const startConversation = useCallback(async (participantIds: number[]) => {
    const res = await chatService.createConversation(participantIds);
    setConversations((prev) => [res.data, ...prev]);
    return res.data;
  }, []);

  return (
    <ChatContext.Provider
      value={{
        conversations,
        currentConversation,
        messages,
        connected,
        typingUsers,
        loadConversations,
        selectConversation,
        sendMessage,
        startConversation,
      }}
    >
      {children}
    </ChatContext.Provider>
  );
}

export function useChat(): ChatContextType {
  const ctx = useContext(ChatContext);
  if (!ctx) throw new Error("useChat must be used within ChatProvider");
  return ctx;
}
