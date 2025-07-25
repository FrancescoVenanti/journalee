import 'package:intl/intl.dart';

class DateHelpers {
  // Date formatters
  static final DateFormat _dayMonthYear = DateFormat('MMM d, yyyy');
  static final DateFormat _dayMonth = DateFormat('MMM d');
  static final DateFormat _timeOnly = DateFormat('h:mm a');
  static final DateFormat _dayTime = DateFormat('MMM d, h:mm a');
  static final DateFormat _fullDateTime = DateFormat('MMM d, yyyy h:mm a');
  static final DateFormat _weekday = DateFormat('EEEE');
  static final DateFormat _shortWeekday = DateFormat('EEE');

  /// Format date for display (e.g., "Mar 15, 2024")
  static String formatDate(DateTime date) {
    return _dayMonthYear.format(date);
  }

  /// Format date without year (e.g., "Mar 15")
  static String formatDateShort(DateTime date) {
    return _dayMonth.format(date);
  }

  /// Format time only (e.g., "2:30 PM")
  static String formatTime(DateTime date) {
    return _timeOnly.format(date);
  }

  /// Format date and time (e.g., "Mar 15, 2:30 PM")
  static String formatDateTime(DateTime date) {
    return _dayTime.format(date);
  }

  /// Format full date and time (e.g., "Mar 15, 2024 2:30 PM")
  static String formatFullDateTime(DateTime date) {
    return _fullDateTime.format(date);
  }

  /// Format weekday (e.g., "Monday")
  static String formatWeekday(DateTime date) {
    return _weekday.format(date);
  }

  /// Format short weekday (e.g., "Mon")
  static String formatShortWeekday(DateTime date) {
    return _shortWeekday.format(date);
  }

  /// Get relative time (e.g., "2 hours ago", "Yesterday", "Last week")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? 'Last week' : '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'Last month' : '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'Last year' : '${years}y ago';
    }
  }

  /// Get smart date format based on how recent the date is
  static String getSmartDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Today - show time
      return 'Today ${formatTime(date)}';
    } else if (difference.inDays == 1) {
      // Yesterday - show "Yesterday" with time
      return 'Yesterday ${formatTime(date)}';
    } else if (difference.inDays < 7) {
      // This week - show weekday with time
      return '${formatShortWeekday(date)} ${formatTime(date)}';
    } else if (difference.inDays < 365) {
      // This year - show date without year
      return formatDateShort(date);
    } else {
      // Previous years - show full date
      return formatDate(date);
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return startOfDay.subtract(Duration(days: date.weekday - 1));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final startOfWeek = DateHelpers.startOfWeek(date);
    return startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(milliseconds: 1));
  }

  /// Get greeting based on time of day
  static String getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Format duration (e.g., "2h 30m", "45s")
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final startOfToday = startOfDay(now);
    final startOfTargetDay = startOfDay(date);
    return startOfTargetDay.difference(startOfToday).inDays;
  }

  /// Get days since date
  static int daysSince(DateTime date) {
    final now = DateTime.now();
    final startOfToday = startOfDay(now);
    final startOfTargetDay = startOfDay(date);
    return startOfToday.difference(startOfTargetDay).inDays;
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Parse date string safely
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get ordinal suffix for day (e.g., "1st", "2nd", "3rd", "4th")
  static String getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }

    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  /// Format date with ordinal (e.g., "March 15th, 2024")
  static String formatDateWithOrdinal(DateTime date) {
    final monthYear = DateFormat('MMMM yyyy').format(date);
    final dayWithOrdinal = getOrdinalSuffix(date.day);
    return '${DateFormat('MMMM').format(date)} $dayWithOrdinal, ${date.year}';
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Get list of dates in a range
  static List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (current.isBefore(endDate) || isSameDay(current, endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Get the first day of the week containing the given date
  static DateTime getFirstDayOfWeek(DateTime date,
      {int firstDayOfWeek = DateTime.monday}) {
    final daysFromFirstDay = (date.weekday - firstDayOfWeek) % 7;
    return startOfDay(date.subtract(Duration(days: daysFromFirstDay)));
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
}
