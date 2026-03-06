
// Formats an ISO datetime string like '2026-03-06T14:30:00' into a relative time string (e.g. '2 hours ago')
String timeAgo(String isoDateString) {
  try {
    final date = DateTime.parse(isoDateString);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  } catch (_) {
    return isoDateString;
  }
}

String formatDate(String isoDateString) {
  try {
    final date = DateTime.parse(isoDateString);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  } catch (_) {
    return isoDateString;
  }
}

String formatTime(String isoTimeString) {
  try {
    // Handle 'HH:mm:ss'
    final parts = isoTimeString.split(':');
    if (parts.length < 2) return isoTimeString;
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $amPm';
  } catch (_) {
    return isoTimeString;
  }
}
