import 'package:timeago/timeago.dart' as timeago;

String formatTimeAgo(DateTime dateTime) {
  return timeago.format(dateTime, allowFromNow: true);
}

List<String> generateSearchKeywords(String title, String body) {
  final text = '$title $body'.toLowerCase();
  final words = text.split(RegExp(r'\s+')).where((w) => w.length > 2).toSet();
  return words.toList();
}
/*
String getInitials(String name) {
  return name
      .split(' ')
      .map((n) => n.isNotEmpty ? n[0] : '')
      .join()
      .toUpperCase()
      .substring(0, name.split(' ').length > 1 ? 2 : 1);
}
*/
String getInitials(String name) {
  if (name.trim().isEmpty) return '?';
  final parts = name.trim().split(' ').where((n) => n.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
