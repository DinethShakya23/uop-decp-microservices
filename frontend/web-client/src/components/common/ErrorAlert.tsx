interface ErrorAlertProps {
  message: string;
  onClose?: () => void;
}

export default function ErrorAlert({ message, onClose }: ErrorAlertProps) {
  if (!message) return null;
  return (
    <div className="mb-4 flex items-center justify-between rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-red-700">
      <span className="text-sm">{message}</span>
      {onClose && (
        <button
          onClick={onClose}
          className="ml-4 text-red-500 hover:text-red-700"
        >
          ✕
        </button>
      )}
    </div>
  );
}
