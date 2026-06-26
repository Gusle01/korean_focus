import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/focus_session.dart';
import '../models/transport_type.dart';

const sessionsBoxName = 'sessions';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// 오늘 완료된 세션들의 집중 시간 합(초). (테스트 가능한 순수 함수)
int todayFocusedSeconds(Iterable<FocusSession> sessions, DateTime now) => sessions
    .where((s) => s.completed && isSameDay(s.startedAt, now))
    .fold(0, (sum, s) => sum + s.focusedSeconds);

/// 완료된 전체 세션의 집중 시간 합(초). (테스트 가능한 순수 함수)
int totalFocusedSeconds(Iterable<FocusSession> sessions) => sessions
    .where((s) => s.completed)
    .fold(0, (sum, s) => sum + s.focusedSeconds);

/// 연속 집중일(스트릭): 완주한 세션이 있는 날을 하루로 보고,
/// 오늘(또는 오늘 아직이라면 어제)부터 거꾸로 연속된 날의 수를 센다.
/// 오늘 집중 전이라도 어제까지의 연속이 끊긴 것으로 보지 않는다.
/// (테스트 가능한 순수 함수)
int focusStreak(Iterable<FocusSession> sessions, DateTime now) {
  final days = <DateTime>{
    for (final s in sessions.where((s) => s.completed)) _dayOf(s.startedAt),
  };
  if (days.isEmpty) return 0;
  var cursor = _dayOf(now);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// 하루치 집중 시간 묶음(주간 그래프용).
class DaySeconds {
  const DaySeconds(this.day, this.seconds);
  final DateTime day;
  final int seconds;
}

/// now를 포함한 최근 [count]일의 완주 집중 시간(초). 과거→오늘 순.
/// (테스트 가능한 순수 함수)
List<DaySeconds> recentDaysSeconds(
  Iterable<FocusSession> sessions,
  DateTime now, {
  int count = 7,
}) {
  final today = _dayOf(now);
  final result = <DaySeconds>[];
  for (var i = count - 1; i >= 0; i--) {
    final day = today.subtract(Duration(days: i));
    final secs = sessions
        .where((s) => s.completed && isSameDay(s.startedAt, day))
        .fold(0, (sum, s) => sum + s.focusedSeconds);
    result.add(DaySeconds(day, secs));
  }
  return result;
}

/// 교통수단별 완주 횟수. (테스트 가능한 순수 함수)
Map<TransportType, int> transportCompletedCounts(
    Iterable<FocusSession> sessions) {
  final counts = {for (final t in TransportType.values) t: 0};
  for (final s in sessions.where((s) => s.completed)) {
    final t = TransportType.values[s.transportIndex];
    counts[t] = counts[t]! + 1;
  }
  return counts;
}

/// Hive 박스를 감싸 세션 저장/조회/집계를 담당.
class SessionRepository {
  SessionRepository(this._box);
  final Box<FocusSession> _box;

  Future<void> save(FocusSession session) => _box.put(session.id, session);

  List<FocusSession> all() {
    final list = _box.values.toList();
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  /// 홈에 보여줄 "최근 완료한 여정".
  List<FocusSession> recent({int limit = 5}) =>
      all().where((s) => s.completed).take(limit).toList();

  int todaySeconds([DateTime? now]) =>
      todayFocusedSeconds(_box.values, now ?? DateTime.now());

  int totalSeconds() => totalFocusedSeconds(_box.values);

  /// 연속 집중일.
  int streak([DateTime? now]) => focusStreak(_box.values, now ?? DateTime.now());

  /// 최근 7일 집중 시간(주간 그래프용).
  List<DaySeconds> recentDays({DateTime? now, int count = 7}) =>
      recentDaysSeconds(_box.values, now ?? DateTime.now(), count: count);

  /// 완주한 세션 수.
  int completedCount() => _box.values.where((s) => s.completed).length;

  /// 시작한 전체 세션 수(중단 포함).
  int totalCount() => _box.length;

  /// 교통수단별 완주 횟수.
  Map<TransportType, int> transportCounts() =>
      transportCompletedCounts(_box.values);
}

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(Hive.box<FocusSession>(sessionsBoxName)),
);
