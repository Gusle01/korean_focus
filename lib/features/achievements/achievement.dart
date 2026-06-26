import '../../data/models/focus_session.dart';
import '../../data/models/transport_type.dart';
import '../../data/repositories/session_repository.dart';

/// 업적 계산에 필요한 집계(완료 세션 + 수집 종수에서 도출).
class AchievementStat {
  const AchievementStat({
    required this.completed,
    required this.distinctDest,
    required this.night,
    required this.morning,
    required this.bus,
    required this.train,
    required this.air,
    required this.totalSeconds,
    required this.maxSeconds,
    required this.streak,
    required this.collectibles,
  });

  final int completed;
  final int distinctDest;
  final int night;
  final int morning;
  final int bus;
  final int train;
  final int air;
  final int totalSeconds;
  final int maxSeconds;
  final int streak;
  final int collectibles;

  factory AchievementStat.from(
      Iterable<FocusSession> sessions, int collectiblesDistinct, DateTime now) {
    var completed = 0, night = 0, morning = 0;
    var bus = 0, train = 0, air = 0, total = 0, maxS = 0;
    final cities = <String>{};
    for (final s in sessions.where((s) => s.completed)) {
      completed++;
      final h = s.startedAt.hour;
      if (h >= 20 || h < 5) night++;
      if (h >= 5 && h < 9) morning++;
      cities.add(s.destName);
      total += s.focusedSeconds;
      if (s.focusedSeconds > maxS) maxS = s.focusedSeconds;
      switch (TransportType.values[s.transportIndex]) {
        case TransportType.bus:
          bus++;
        case TransportType.train:
          train++;
        case TransportType.airplane:
          air++;
      }
    }
    return AchievementStat(
      completed: completed,
      distinctDest: cities.length,
      night: night,
      morning: morning,
      bus: bus,
      train: train,
      air: air,
      totalSeconds: total,
      maxSeconds: maxS,
      streak: focusStreak(sessions, now),
      collectibles: collectiblesDistinct,
    );
  }
}

/// 하나의 칭호/업적 정의. [progressOf]가 [target] 이상이면 달성.
class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.desc,
    required this.target,
    required this.progressOf,
  });

  final String id;
  final String emoji;
  final String title;
  final String desc;
  final int target;
  final int Function(AchievementStat) progressOf;
}

class AchievementStatus {
  const AchievementStatus(this.achievement, this.progress, this.unlocked);
  final Achievement achievement;
  final int progress;
  final bool unlocked;
}

/// 전체 칭호 목록(완주·지역·시간대·교통수단·스트릭·수집 기반).
final achievements = <Achievement>[
  Achievement(
      id: 'first',
      emoji: '🎫',
      title: '첫 여정',
      desc: '첫 집중을 완주',
      target: 1,
      progressOf: (s) => s.completed),
  Achievement(
      id: 'regular',
      emoji: '🧳',
      title: '단골 여행자',
      desc: '집중 10회 완주',
      target: 10,
      progressOf: (s) => s.completed),
  Achievement(
      id: 'master',
      emoji: '🏔️',
      title: '백두대간 종주',
      desc: '집중 50회 완주',
      target: 50,
      progressOf: (s) => s.completed),
  Achievement(
      id: 'nation',
      emoji: '🗺️',
      title: '전국구',
      desc: '10개 지역에 도착',
      target: 10,
      progressOf: (s) => s.distinctDest),
  Achievement(
      id: 'night',
      emoji: '🌙',
      title: '야간열차 마니아',
      desc: '밤에 10회 완주',
      target: 10,
      progressOf: (s) => s.night),
  Achievement(
      id: 'dawn',
      emoji: '🌅',
      title: '새벽 출발',
      desc: '아침에 5회 완주',
      target: 5,
      progressOf: (s) => s.morning),
  Achievement(
      id: 'streak7',
      emoji: '🔥',
      title: '일주일 연속',
      desc: '7일 연속 집중',
      target: 7,
      progressOf: (s) => s.streak),
  Achievement(
      id: 'pilot',
      emoji: '✈️',
      title: '마일리지 적립',
      desc: '비행기로 10회 완주',
      target: 10,
      progressOf: (s) => s.air),
  Achievement(
      id: 'allmodes',
      emoji: '🚉',
      title: '만석',
      desc: '세 교통수단 모두 완주',
      target: 3,
      progressOf: (s) =>
          (s.bus > 0 ? 1 : 0) + (s.train > 0 ? 1 : 0) + (s.air > 0 ? 1 : 0)),
  Achievement(
      id: 'long',
      emoji: '⏳',
      title: '장거리 집중',
      desc: '한 번에 90분 이상',
      target: 1,
      progressOf: (s) => s.maxSeconds >= 90 * 60 ? 1 : 0),
  Achievement(
      id: 'collector',
      emoji: '🎁',
      title: '도감 수집가',
      desc: '특산품 15종 수집',
      target: 15,
      progressOf: (s) => s.collectibles),
  Achievement(
      id: 'tenhours',
      emoji: '⭐',
      title: '누적 10시간',
      desc: '총 10시간 집중',
      target: 1,
      progressOf: (s) => s.totalSeconds >= 10 * 3600 ? 1 : 0),
];

List<AchievementStatus> evaluateAchievements(AchievementStat stat) => [
      for (final a in achievements)
        AchievementStatus(
          a,
          a.progressOf(stat).clamp(0, a.target),
          a.progressOf(stat) >= a.target,
        ),
    ];

int unlockedCount(AchievementStat stat) =>
    achievements.where((a) => a.progressOf(stat) >= a.target).length;
