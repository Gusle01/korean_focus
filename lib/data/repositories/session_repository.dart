import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/focus_session.dart';

const sessionsBoxName = 'sessions';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 오늘 완료된 세션들의 집중 시간 합(초). (테스트 가능한 순수 함수)
int todayFocusedSeconds(Iterable<FocusSession> sessions, DateTime now) => sessions
    .where((s) => s.completed && isSameDay(s.startedAt, now))
    .fold(0, (sum, s) => sum + s.focusedSeconds);

/// 완료된 전체 세션의 집중 시간 합(초). (테스트 가능한 순수 함수)
int totalFocusedSeconds(Iterable<FocusSession> sessions) => sessions
    .where((s) => s.completed)
    .fold(0, (sum, s) => sum + s.focusedSeconds);

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
}

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(Hive.box<FocusSession>(sessionsBoxName)),
);
