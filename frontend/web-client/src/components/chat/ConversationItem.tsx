import type { ConversationResponse } from "../../types";
import { formatRelativeTime } from "../../utils/formatDate";

interface ConversationItemProps {
  conversation: ConversationResponse;
  currentUserId: number;
  selected?: boolean;
  onClick: () => void;
}

export default function ConversationItem({
  conversation,
  currentUserId,
  selected,
  onClick,
}: ConversationItemProps) {
  const otherNames = conversation.participantNames.filter(
    (_, i) => conversation.participants[i] !== currentUserId,
  );
  const displayName =
    otherNames.length > 0 ? otherNames.join(", ") : "Conversation";

  return (
    <button
      onClick={onClick}
      className={`flex w-full items-center gap-3 rounded-lg p-3 text-left transition-colors ${
        selected ? "bg-primary-50" : "hover:bg-gray-50"
      }`}
    >
      <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-full bg-primary-100 text-sm font-semibold text-primary-700">
        {displayName.charAt(0).toUpperCase()}
      </div>
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-medium text-gray-900">
          {displayName}
        </p>
        <p className="truncate text-xs text-gray-500">
          {conversation.lastMessage || "No messages yet"}
        </p>
      </div>
      {conversation.lastMessageAt && (
        <span className="flex-shrink-0 text-xs text-gray-400">
          {formatRelativeTime(conversation.lastMessageAt)}
        </span>
      )}
    </button>
  );
}
