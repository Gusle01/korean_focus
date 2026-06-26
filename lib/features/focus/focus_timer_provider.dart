import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/active_journey_repository.dart';

/// 타임스탬프 기반 타이머 상태. 카운터를 직접 깎지 않고 startedAt 기준으로
/// 매번 경과를 계산하므로 백그라운드/복귀에도 정확하다.
class TimerState {
  final DateTime startedAt;
  final Duration planned;
  final Duration pausedAccum; // 누적 정지시간
  final DateTime? pausedAt; // 정지 중이면 시각
  final bool finished;

  const TimerState({
    required this.startedAt,
    required this.planned,
    this.pausedAccum = Duration.zero,
    this.pausedAt,
    this.finished = false,
  });

  bool get isPaused => pausedAt != null;

  Duration elapsedAt(DateTime now) {
    final pausedNow =
        pausedAt != null ? now.difference(pausedAt!) : Duration.zero;
    final e = now.difference(startedAt) - pausedAccum - pausedNow;
    return e.isNegative ? Duration.zero : e;
  }

  Duration remainingAt(DateTime now) {
    final r = planned - elapsedAt(now);
    return r.isNegative ? Duration.zero : r;
  }

  double progressAt(DateTime now) {
    if (planned.inMilliseconds == 0) return 1;
    return (elapsedAt(now).inMilliseconds / planned.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  bool isOverAt(DateTime now) => elapsedAt(now) >= planned;

  TimerState copyWith({
    Duration? pausedAccum,
    DateTime? pausedAt,
    bool clearPaused = false,
    bool? finished,
  }) =>
      TimerState(
        startedAt: startedAt,
        planned: planned,
        pausedAccum: pausedAccum ?? this.pausedAccum,
        pausedAt: clearPaused ? null : (pausedAt ?? this.pausedAt),
        finished: finished ?? this.finished,
      );
}

class FocusTimerNotifier extends Notifier<TimerState?> {
  Timer? _ticker;

  @override
  TimerState? build() {
    ref.onDispose(() => _ticker?.cancel());
    // 앱 재실행 시 진행 중 여정이 있으면 타임스탬프 기준으로 타이머를 복원한다.
    final snap = hasActiveJourney()
        ? ref.read(activeJourneyRepositoryProvider).read()
        : null;
    if (snap != null) {
      final restored = TimerState(
        startedAt: snap.startedAt,
        planned: Duration(seconds: snap.plannedSeconds),
        pausedAccum: Duration(seconds: snap.pausedAccumSeconds),
        pausedAt: snap.pausedAt,
      );
      // 떠나 있는 동안 이미 도착(완료)했으면 finished 로 복원.
      if (restored.isOverAt(DateTime.now())) {
        return restored.copyWith(finished: true);
      }
      // 진행 중이고 정지 상태가 아니면 틱 재개.
      if (!restored.isPaused) {
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
      return restored;
    }
    return null;
  }

  void start(Duration planned) {
    _ticker?.cancel();
    state = TimerState(startedAt: DateTime.now(), planned: planned);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    final s = state;
    if (s == null || s.isPaused || s.finished) return;
    state = s.copyWith(pausedAt: DateTime.now());
  }

  void resume() {
    final s = state;
    if (s == null || !s.isPaused) return;
    final added = DateTime.now().difference(s.pausedAt!);
    state = s.copyWith(pausedAccum: s.pausedAccum + added, clearPaused: true);
  }

  /// 백그라운드 복귀 시 즉시 동기화(완료 감지 포함).
  void syncNow() => _tick();

  void _tick() {
    final s = state;
    if (s == null || s.finished || s.isPaused) return;
    if (s.isOverAt(DateTime.now())) {
      _ticker?.cancel();
      state = s.copyWith(finished: true);
    } else {
      state = s.copyWith(); // 새 인스턴스로 리빌드 유발 → UI가 now로 재계산
    }
  }

  void cancel() {
    _ticker?.cancel();
    state = null;
  }
}

final focusTimerProvider =
    NotifierProvider<FocusTimerNotifier, TimerState?>(FocusTimerNotifier.new);
