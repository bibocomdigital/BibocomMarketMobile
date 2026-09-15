dynamic unwrapApi(dynamic raw) {
  var current = raw;
  var hops = 0;
  while (current is Map &&
      hops < 3 &&
      current['success'] == true &&
      current.containsKey('data')) {
    current = current['data'];
    hops++;
  }
  return current;
}

Map<String, dynamic> unwrapApiMap(dynamic raw) {
  final unwrapped = unwrapApi(raw);
  if (unwrapped is Map<String, dynamic>) return unwrapped;
  if (unwrapped is Map) return Map<String, dynamic>.from(unwrapped);
  throw const FormatException('Réponse API inattendue.');
}

List<dynamic> unwrapApiList(dynamic raw) {
  final unwrapped = unwrapApi(raw);
  if (unwrapped is List) return unwrapped;
  if (unwrapped is Map) {
    for (final key in [
      'items',
      'products',
      'shops',
      'orders',
      'notifications',
      'messages',
      'conversations',
      'categories',
      'comments',
      'following',
      'followers',
    ]) {
      final value = unwrapped[key];
      if (value is List) return value;
    }
  }
  return const [];
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  return fallback;
}

Map<String, dynamic>? asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
