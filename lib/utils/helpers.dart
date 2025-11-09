import 'package:intl/intl.dart';

String fmtDate(DateTime? d) {
  if (d == null) return '';
  return DateFormat.yMMMd().add_jm().format(d);
}

bool isDueSoon(DateTime? d) {
  if (d == null) return false;
  final now = DateTime.now();
  return d.isAfter(now) && d.isBefore(now.add(const Duration(hours:24)));
}

bool isToday(DateTime? d) {
  if (d == null) return false;
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}
