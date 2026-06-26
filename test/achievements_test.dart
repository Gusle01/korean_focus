import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/data/models/focus_session.dart';
import 'package:korean_focus/features/achievements/achievement.dart';

FocusSession _s({
  required int transportIndex,
  required int focusedSeconds,
  required DateTime startedAt,
  required String destName,
  bool completed = true,
}) =>
    FocusSession(
      id: startedAt.microsecondsSinceEpoch.toString(),
      originName: '출발',
      destName: destName,
      transportIndex: transportIndex,
      plannedSeconds: focusedSeconds,
      focusedSeconds: focusedSeconds,
      startedAt: startedAt,
      completed: completed,
    );

void main() {
  final now = DateTime(2026, 6, 27, 12);

  test('완료 세션 집계가 정확하다(중단 세션 제외)', () {
    final sessions = [
      _s(transportIndex: 1, focusedSeconds: 3600, startedAt: DateTime(2026, 6, 27, 22), destName: '부산역'),
      _s(transportIndex: 2, focusedSeconds: 5400, startedAt: DateTime(2026, 6, 27, 7), destName: '제주공항'),
      _s(transportIndex: 0, focusedSeconds: 1800, startedAt: DateTime(2026, 6, 26, 14), destName: '부산역', completed: false),
    ];
    final stat = AchievementStat.from(sessions, 3, now);
    expect(stat.completed, 2);
    expect(stat.night, 1); // 22시
    expect(stat.morning, 1); // 7시
    expect(stat.air, 1);
    expect(stat.train, 1);
    expect(stat.bus, 0);
    expect(stat.distinctDest, 2);
    expect(stat.maxSeconds, 5400);
    expect(stat.totalSeconds, 9000);
    expect(stat.collectibles, 3);
  });

  test('첫 여정·장거리·만석 업적이 평가된다', () {
    final sessions = [
      _s(transportIndex: 1, focusedSeconds: 5400, startedAt: DateTime(2026, 6, 27, 10), destName: '부산역'),
    ];
    final stat = AchievementStat.from(sessions, 0, now);
    final byId = {for (final e in evaluateAchievements(stat)) e.achievement.id: e};
    expect(byId['first']!.unlocked, isTrue);
    expect(byId['long']!.unlocked, isTrue); // 90분
    expect(byId['allmodes']!.unlocked, isFalse);
    expect(byId['allmodes']!.progress, 1); // 기차만
    expect(byId['regular']!.unlocked, isFalse);
    expect(byId['regular']!.progress, 1); // 1/10
  });

  test('빈 기록은 달성 0', () {
    final stat = AchievementStat.from(const [], 0, now);
    expect(unlockedCount(stat), 0);
  });
}
