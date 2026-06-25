import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// iOS Live Activity / 다이나믹 아일랜드 제어용 네이티브 브릿지.
///
/// 위젯이 시작~종료 시각 구간으로 스스로 카운트다운하므로(timerInterval),
/// 앱은 시작·일시정지·재개·종료 때만 호출한다. 미지원/구버전에서는 조용히 무시.
class LiveActivityBridge {
  static const _channel = MethodChannel('korean_focus/live_activity');

  bool get _supported => Platform.isIOS;

  /// 여정 시작 → Live Activity 생성. 실패 시 null.
  Future<String?> start({
    required String origin,
    required String dest,
    required String transportEmoji,
    required int startMs,
    required int endMs,
    required bool paused,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<String>('start', {
        'origin': origin,
        'dest': dest,
        'emoji': transportEmoji,
        'startMs': startMs,
        'endMs': endMs,
        'paused': paused,
        'remaining': remainingSeconds,
        'progress': progress,
      });
    } catch (_) {
      return null;
    }
  }

  /// 상태 변경(일시정지/재개) 시 갱신.
  Future<void> update({
    required int startMs,
    required int endMs,
    required bool paused,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('update', {
        'startMs': startMs,
        'endMs': endMs,
        'paused': paused,
        'remaining': remainingSeconds,
        'progress': progress,
      });
    } catch (_) {}
  }

  /// 여정 종료(도착/중단) → Live Activity 제거.
  Future<void> end({String? arrivedAt}) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('end', {'arrivedAt': arrivedAt});
    } catch (_) {}
  }
}
