import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// iOS Live Activity / 다이나믹 아일랜드 제어용 네이티브 브릿지.
///
/// 네이티브(Swift) 쪽 ActivityKit 구현과 MethodChannel 로 통신한다.
/// Live Activity 위젯 익스텐션 타깃이 추가돼 있어야 실제로 표시되며
/// (ios/LIVE_ACTIVITY_SETUP.md 참고), 미구현/구버전 iOS 에서는
/// 호출이 조용히 무시되도록 모든 호출을 try/catch 로 감싼다.
class LiveActivityBridge {
  static const _channel = MethodChannel('korean_focus/live_activity');

  bool get _supported => Platform.isIOS;

  /// 여정 시작 → Live Activity 생성. 실패 시 null.
  Future<String?> start({
    required String origin,
    required String dest,
    required String transportEmoji,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_supported) return null;
    try {
      final id = await _channel.invokeMethod<String>('start', {
        'origin': origin,
        'dest': dest,
        'emoji': transportEmoji,
        'remaining': remainingSeconds,
        'progress': progress,
      });
      return id;
    } catch (_) {
      return null;
    }
  }

  Future<void> update({
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('update', {
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
