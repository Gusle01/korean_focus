import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/data/models/focus_session.dart';
import 'package:korean_focus/data/models/transport_type.dart';
import 'package:korean_focus/data/repositories/session_repository.dart';

FocusSession session({
  required DateTime startedAt,
  bool completed = true,
  int focusedSeconds = 1500,
  TransportType transport = TransportType.train,
}) =>
    FocusSession(
      id: '${startedAt.microsecondsSinceEpoch}_${transport.index}',
      originName: '서울',
      destName: '부산',
      transportIndex: transport.index,
      plannedSeconds: 1500,
      focusedSeconds: focusedSeconds,
      startedAt: startedAt,
      completed: completed,
    );

void main() {
  final now = DateTime(2026, 6, 26, 14);
  DateTime daysAgo(int n) => DateTime(2026, 6, 26 - n, 10);

  group('focusStreak', () {
    test('기록이 없으면 0', () {
      expect(focusStreak(const [], now), 0);
    });

    test('오늘 완주가 있으면 오늘부터 연속을 센다', () {
      final sessions = [
        session(startedAt: daysAgo(0)),
        session(startedAt: daysAgo(1)),
        session(startedAt: daysAgo(2)),
      ];
      expect(focusStreak(sessions, now), 3);
    });

    test('오늘 아직 안 했어도 어제까지의 연속은 유지된다', () {
      final sessions = [
        session(startedAt: daysAgo(1)),
        session(startedAt: daysAgo(2)),
      ];
      expect(focusStreak(sessions, now), 2);
    });

    test('어제·오늘 모두 없으면 0', () {
      final sessions = [session(startedAt: daysAgo(2))];
      expect(focusStreak(sessions, now), 0);
    });

    test('중간에 빈 날이 있으면 거기서 끊긴다', () {
      final sessions = [
        session(startedAt: daysAgo(0)),
        session(startedAt: daysAgo(1)),
        // daysAgo(2) 없음
        session(startedAt: daysAgo(3)),
      ];
      expect(focusStreak(sessions, now), 2);
    });

    test('완주하지 않은 세션은 스트릭에 포함되지 않는다', () {
      final sessions = [
        session(startedAt: daysAgo(0), completed: false),
        session(startedAt: daysAgo(1)),
      ];
      expect(focusStreak(sessions, now), 1);
    });

    test('같은 날 여러 세션도 하루로 센다', () {
      final sessions = [
        session(startedAt: DateTime(2026, 6, 26, 9)),
        session(startedAt: DateTime(2026, 6, 26, 20)),
        session(startedAt: daysAgo(1)),
      ];
      expect(focusStreak(sessions, now), 2);
    });
  });

  group('recentDaysSeconds', () {
    test('항상 count일을 과거→오늘 순으로 반환한다', () {
      final days = recentDaysSeconds(const [], now, count: 7);
      expect(days.length, 7);
      expect(days.first.day, DateTime(2026, 6, 20));
      expect(days.last.day, DateTime(2026, 6, 26));
      expect(days.every((d) => d.seconds == 0), isTrue);
    });

    test('해당 날의 완주 집중 시간만 합산한다', () {
      final sessions = [
        session(startedAt: daysAgo(0), focusedSeconds: 600),
        session(startedAt: daysAgo(0), focusedSeconds: 300),
        session(startedAt: daysAgo(0), completed: false, focusedSeconds: 999),
        session(startedAt: daysAgo(1), focusedSeconds: 1200),
      ];
      final days = recentDaysSeconds(sessions, now, count: 7);
      expect(days.last.seconds, 900); // 오늘: 600+300, 미완주 제외
      expect(days[5].seconds, 1200); // 어제
    });

    test('범위 밖(오래된) 세션은 포함되지 않는다', () {
      final sessions = [session(startedAt: daysAgo(10), focusedSeconds: 600)];
      final days = recentDaysSeconds(sessions, now, count: 7);
      expect(days.fold<int>(0, (s, d) => s + d.seconds), 0);
    });
  });

  group('transportCompletedCounts', () {
    test('교통수단별 완주 횟수를 세고 미완주는 제외한다', () {
      final sessions = [
        session(startedAt: daysAgo(0), transport: TransportType.train),
        session(startedAt: daysAgo(1), transport: TransportType.train),
        session(startedAt: daysAgo(2), transport: TransportType.bus),
        session(
            startedAt: daysAgo(3),
            transport: TransportType.airplane,
            completed: false),
      ];
      final counts = transportCompletedCounts(sessions);
      expect(counts[TransportType.train], 2);
      expect(counts[TransportType.bus], 1);
      expect(counts[TransportType.airplane], 0);
    });

    test('모든 교통수단 키가 항상 존재한다', () {
      final counts = transportCompletedCounts(const []);
      expect(counts.keys.toSet(), TransportType.values.toSet());
      expect(counts.values.every((v) => v == 0), isTrue);
    });
  });
}
