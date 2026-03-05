import type { MessageResponse } from "../../types";
import { formatRelativeTime } from "../../utils/formatDate";

interface MessageBubbleProps {
  message: MessageResponse;
  isOwn: boolean;
}

export default function MessageBubble({ message, isOwn }: MessageBubbleProps) {
  return (
    <div className={`flex ${isOwn ? "justify-end" : "justify-start"}`}>
      <div
        className={`max-w-[70%] rounded-2xl px-4 py-2.5 ${
          isOwn
            ? "rounded-br-md bg-primary-600 text-white"
            : "rounded-bl-md bg-gray-100 text-gray-900"
        }`}
      >
        {!isOwn && (
          <p className="mb-0.5 text-xs font-medium text-primary-600">
            {message.senderName}
          </p>
        )}
        <p className="text-sm">{message.content}</p>
        <p
          className={`mt-1 text-right text-[10px] ${isOwn ? "text-primary-200" : "text-gray-400"}`}
        >
          {formatRelativeTime(message.createdAt)}
        </p>
      </div>
    </div>
  );
}
