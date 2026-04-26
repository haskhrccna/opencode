import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';

/// Extensions for DateTime operations
extension DateTimeExtensions on DateTime {
  /// Format date to Arabic locale
  String toArabicDateString({String format = AppConstants.dateFormat}) {
    final formatter = DateFormat(format, 'ar');
    return formatter.format(this);
  }

  /// Format time to Arabic locale
  String toArabicTimeString({String format = AppConstants.timeFormat}) {
    final formatter = DateFormat(format, 'ar');
    return formatter.format(this);
  }

  /// Format datetime to Arabic locale
  String toArabicDateTimeString({String format = AppConstants.dateTimeFormat}) {
    final formatter = DateFormat(format, 'ar');
    return formatter.format(this);
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day + 1).subtract(const Duration(microseconds: 1));

  /// Get start of week (Saturday for Arabic calendar)
  DateTime get startOfWeek {
    final diff = (weekday + 1) % 7;
    return subtract(Duration(days: diff)).startOfDay;
  }

  /// Get end of week (Friday for Arabic calendar)
  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth {
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextMonthYear = month == 12 ? year + 1 : year;
    return DateTime(nextMonthYear, nextMonth, 0).endOfDay;
  }

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Get difference in days
  int differenceInDays(DateTime other) => difference(other).inDays;

  /// Get Arabic day name
  String get arabicDayName {
    final names = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    return names[weekday % 7];
  }

  /// Get Arabic month name
  String get arabicMonthName {
    final names = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return names[month - 1];
  }

  /// Get Hijri month name (approximate)
  String get hijriMonthName {
    final names = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    // Approximate conversion - for exact use hijri_date package
    final hijriMonth = ((month + 2) % 12);
    return names[(hijriMonth + 11) % 12];
  }

  /// Format relative time
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'منذ لحظات';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }

  /// Check if two dates are the same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if date is in current week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfCurrentWeek = now.startOfWeek;
    final endOfCurrentWeek = now.endOfWeek;
    return !isBefore(startOfCurrentWeek) && !isAfter(endOfCurrentWeek);
  }

  /// Check if date is in current month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Get age from birth date
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}

/// Extensions for Duration
extension DurationExtensions on Duration {
  /// Format duration to readable string
  String toArabicString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours ساعة');
    }
    if (minutes > 0) {
      parts.add('$minutes دقيقة');
    }
    if (seconds > 0 && hours == 0) {
      parts.add('$seconds ثانية');
    }

    return parts.join(' و ');
  }

  /// Format to short string (HH:MM)
  String toShortString() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
