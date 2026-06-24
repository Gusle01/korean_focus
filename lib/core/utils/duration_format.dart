/// 분 → "1시간 40분" / "2시간" / "40분"
String formatMinutesKo(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m > 0) return '$h시간 $m분';
  if (h > 0) return '$h시간';
  return '$m분';
}

/// 초 → "00:38:12" (타이머 표시용)
String formatClock(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(h)}:${two(m)}:${two(s)}';
}

/// 초 → "1시간 12분" (누적 집중시간 표시용)
String formatDurationKo(int seconds) {
  final totalMinutes = seconds ~/ 60;
  if (totalMinutes <= 0) return '0분';
  return formatMinutesKo(totalMinutes);
}
