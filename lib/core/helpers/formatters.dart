import 'package:intl/intl.dart';

abstract final class MoneyFormat {
  static final _fcfa = NumberFormat.decimalPattern('fr');

  static String fcfa(num amount) => '${_fcfa.format(amount.round())} FCFA';
}

abstract final class PhoneFormat {
  static String mali(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('223')) return '+$digits';
    if (digits.length == 8) return '+223 $digits';
    return raw.startsWith('+') ? raw : '+223 $digits';
  }

  static String digitsForWhatsApp(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('223')) return digits;
    if (digits.length == 8) return '223$digits';
    return digits;
  }
}

abstract final class DateFormatFr {
  static final _day = DateFormat('dd/MM/yyyy', 'fr');

  static String day(DateTime date) => _day.format(date.toLocal());

  static DateTime? tryParse(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
