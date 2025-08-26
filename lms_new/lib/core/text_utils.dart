String shortText(String? s, {int max = 120}) {
  final str = (s ?? '').trim();
  if (str.length <= max) return str;
  return '${str.substring(0, max).trimRight()}…';
}
