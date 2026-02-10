import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility untuk format dan manipulasi tanggal
class DateFormatter {
  DateFormatter._();

  // Date Formatters
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _databaseFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _reportFormat = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _invoiceFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'id_ID');
  static final DateFormat _backupFormat = DateFormat('yyyyMMdd_HHmmss');
  static final DateFormat _fullFormat =
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

  /// Format untuk display (dd/MM/yyyy)
  static String formatDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Format untuk database (yyyy-MM-dd HH:mm:ss)
  static String formatDatabase(DateTime date) {
    return _databaseFormat.format(date);
  }

  /// Format untuk laporan (dd MMMM yyyy)
  static String formatReport(DateTime date) {
    return _reportFormat.format(date);
  }

  /// Format untuk invoice/nota (dd/MM/yyyy HH:mm)
  static String formatInvoice(DateTime date) {
    return _invoiceFormat.format(date);
  }

  /// Format time only (HH:mm)
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format month year (MMMM yyyy)
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format untuk backup filename (yyyyMMdd_HHmmss)
  static String formatBackup(DateTime date) {
    return _backupFormat.format(date);
  }

  /// Format lengkap (EEEE, dd MMMM yyyy)
  static String formatFull(DateTime date) {
    return _fullFormat.format(date);
  }

  /// Parse dari string database format
  static DateTime? parseDatabase(String dateString) {
    try {
      return _databaseFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse dari string display format
  static DateTime? parseDisplay(String dateString) {
    try {
      return _displayFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get relative time (e.g., "2 jam yang lalu", "Kemarin")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu yang lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan yang lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun yang lalu';
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

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Get date range untuk filter (Today, This Week, This Month, etc.)
  static DateTimeRange getDateRange(String range) {
    final now = DateTime.now();

    switch (range.toLowerCase()) {
      case 'Hari Ini':
        return DateTimeRange(
          start: startOfDay(now),
          end: endOfDay(now),
        );

      case 'Kemarin':
        final yesterday = now.subtract(const Duration(days: 1));
        return DateTimeRange(
          start: startOfDay(yesterday),
          end: endOfDay(yesterday),
        );

      case 'Minggu Ini':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(
          start: startOfDay(startOfWeek),
          end: endOfDay(now),
        );

      case 'Bulan Ini':
        return DateTimeRange(
          start: startOfMonth(now),
          end: endOfDay(now),
        );

      case 'last month':
        final lastMonth = DateTime(now.year, now.month - 1);
        return DateTimeRange(
          start: startOfMonth(lastMonth),
          end: endOfMonth(lastMonth),
        );

      case 'Tahun Ini':
        return DateTimeRange(
          start: startOfYear(now),
          end: endOfDay(now),
        );

      default:
        return DateTimeRange(start: now, end: now);
    }
  }

  /// Format date range untuk display
  static String formatDateRange(DateTimeRange range) {
    if (isToday(range.start) && isToday(range.end)) {
      return 'Hari Ini';
    } else if (isYesterday(range.start) && isYesterday(range.end)) {
      return 'Kemarin';
    } else if (range.start.year == range.end.year &&
        range.start.month == range.end.month) {
      return '${range.start.day} - ${range.end.day} ${formatMonthYear(range.start)}';
    } else {
      return '${formatDisplay(range.start)} - ${formatDisplay(range.end)}';
    }
  }
}

