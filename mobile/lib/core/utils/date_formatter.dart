import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Converts ISO 8601 UTC string to French formatted date.
  /// Example: "2026-08-01T14:30:00Z" → "1 août 2026 à 14h30"
  static String format(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat("d MMMM yyyy 'à' HH'h'mm", 'fr').format(date);
  }

  /// Short format: "1 août 2026"
  static String formatShort(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('d MMMM yyyy', 'fr').format(date);
  }
}
