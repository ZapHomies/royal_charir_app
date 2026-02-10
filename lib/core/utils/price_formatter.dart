import 'package:intl/intl.dart';

/// Utility untuk format harga dalam Rupiah
class PriceFormatter {
  PriceFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyFormatWithDecimals = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 2,
  );

  static final NumberFormat _numberFormat = NumberFormat('#,##0', 'id_ID');

  /// Format harga ke Rupiah (tanpa desimal)
  /// Example: 1000000 -> Rp1.000.000
  static String format(double price) {
    return _currencyFormat.format(price);
  }

  /// Format harga ke Rupiah (dengan desimal)
  /// Example: 1000000.50 -> Rp1.000.000,50
  static String formatWithDecimals(double price) {
    return _currencyFormatWithDecimals.format(price);
  }

  /// Format number (tanpa symbol Rp)
  /// Example: 1000000 -> 1.000.000
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }

  /// Parse string Rupiah ke double
  /// Example: "Rp1.000.000" -> 1000000.0
  static double parse(String priceString) {
    try {
      // Remove Rp symbol, dots, and commas
      final cleanString = priceString
          .replaceAll('Rp', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      return double.parse(cleanString);
    } catch (e) {
      return 0.0;
    }
  }

  /// Format price untuk display di tabel
  /// Example: 1000000 -> "1.000.000"
  static String formatForTable(double price) {
    return _numberFormat.format(price);
  }

  /// Format price dengan prefix custom
  static String formatWithPrefix(double price, String prefix) {
    return '$prefix ${_numberFormat.format(price)}';
  }

  /// Compact format untuk jumlah besar
  /// Example: 1000000 -> "1 Juta"
  static String formatCompact(double price) {
    if (price >= 1000000000) {
      return 'Rp${(price / 1000000000).toStringAsFixed(1)} M';
    } else if (price >= 1000000) {
      return 'Rp${(price / 1000000).toStringAsFixed(1)} Jt';
    } else if (price >= 1000) {
      return 'Rp${(price / 1000).toStringAsFixed(1)} Rb';
    } else {
      return format(price);
    }
  }

  /// Check if string is valid price format
  static bool isValidPrice(String priceString) {
    try {
      parse(priceString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
