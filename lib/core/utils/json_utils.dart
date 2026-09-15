Map<String, dynamic> asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return const {};
}

int asInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double asDouble(Object? value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

String asString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

bool asBool(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final raw = value?.toString().toLowerCase();
  if (raw == 'true' || raw == '1') return true;
  if (raw == 'false' || raw == '0') return false;
  return fallback;
}

List<dynamic> asList(Object? value) {
  if (value is List) return value;
  if (value is Map) {
    for (final key in const [
      'data',
      'items',
      'categories',
      'results',
      'orders',
    ]) {
      final nested = value[key];
      if (nested is List) return nested;
    }
  }
  return const [];
}

String formatCfa(num amount) {
  final digits = amount.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('\u00A0');
    }
    buffer.write(digits[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign$buffer CFA';
}

String formatShortDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}
