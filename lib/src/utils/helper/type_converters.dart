int toInt(dynamic value) {
  if (value == null) return 0;

  if (value is int) return value;

  if (value is String) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return int.parse(cleaned);
  }

  return 0;
}

List<int> toIntList(dynamic value) {
  if (value is List) {
    return value.map((e) => toInt(e)).toList();
  }
  return [];
}

String toStringValue(dynamic value) => value?.toString() ?? '';
