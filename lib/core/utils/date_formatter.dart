class DateFormatter {
  DateFormatter._();

  /// Formats a date relative to today
  /// Today     → "Today"
  /// Yesterday → "Yesterday"
  /// This week → "Mon, 14 Jul"
  /// Older     → "14 Jul 2025"
  static String format(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) {
      // Within last week — show day name and date
      return '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)}';
    }
    // Older — show full date
    // Only show year if it is different from current year
    if (date.year == now.year) {
      return '${date.day} ${_month(date.month)}';
    }
    return '${date.day} ${_month(date.month)} ${date.year}';
  }

  /// Formats a date as month and year only
  /// Used in analytics and budget period headers
  static String monthYear(DateTime date) {
    return '${_month(date.month)} ${date.year}';
  }

  /// Formats a date as full readable string
  /// Used in transaction detail
  static String full(DateTime date) {
    return '${_weekday(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';
  }

  static String _weekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
