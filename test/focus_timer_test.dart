import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/features/focus/focus_timer_provider.dart';

void main() {
  final t0 = DateTime(2026, 6, 25, 10, 0, 0);

  group('TimerState 경과/진행률', () {
    const planned = Duration(minutes: 1); // 60초
    final state = TimerState(startedAt: t0, planned: planned);

    test('중간 시점 경과/남은시간/진행률', () {
      final now = t0.add(const Duration(seconds: 20));
      expect(state.elapsedAt(now), const Duration(seconds: 20));
      expect(state.remainingAt(now), const Duration(seconds: 40));
      expect(state.progressAt(now), closeTo(0.333, 0.01));
      expect(state.isOverAt(now), isFalse);
    });

    test('계획 시간 도달 시 완료/0/100%', () {
      final now = t0.add(const Duration(seconds: 60));
      expect(state.isOverAt(now), isTrue);
      expect(state.remainingAt(now), Duration.zero);
      expect(state.progressAt(now), 1.0);
    });

    test('초과해도 남은시간은 0, 진행률 1.0으로 클램프', () {
      final now = t0.add(const Duration(seconds: 90));
      expect(state.remainingAt(now), Duration.zero);
      expect(state.progressAt(now), 1.0);
    });
  });

  group('일시정지 계산', () {
    const planned = Duration(minutes: 1);

    test('정지 중에는 경과가 멈춘 시점에 고정된다', () {
      final state = TimerState(
        startedAt: t0,
        planned: planned,
        pausedAt: t0.add(const Duration(seconds: 20)),
      );
      // 정지(20s)한 채 50s 시점 → 경과는 20s로 고정
      final now = t0.add(const Duration(seconds: 50));
      expect(state.elapsedAt(now), const Duration(seconds: 20));
    });

    test('누적 정지시간만큼 경과가 줄어든다', () {
      final state = TimerState(
        startedAt: t0,
        planned: planned,
        pausedAccum: const Duration(seconds: 10),
      );
      final now = t0.add(const Duration(seconds: 30));
      expect(state.elapsedAt(now), const Duration(seconds: 20));
    });
  });
}
