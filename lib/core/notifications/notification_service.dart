import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_activity_bridge.dart';

/// 집중 여정의 실시간 상태를 OS 알림으로 보여준다.
///
/// 시간은 클라이언트가 스스로 카운트다운한다(앱이 초당 갱신하지 않음):
/// - Android: ongoing 알림 + chronometer(카운트다운) → 백그라운드에도 매초 똑딱.
/// - iOS: Live Activity(다이나믹 아일랜드/잠금화면)가 timerInterval 로 자동 갱신.
/// 앱은 시작·일시정지·재개·도착 때만 호출한다.
class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    LiveActivityBridge? liveActivity,
  })  : _fln = plugin ?? FlutterLocalNotificationsPlugin(),
        _live = liveActivity ?? LiveActivityBridge();

  final FlutterLocalNotificationsPlugin _fln;
  final LiveActivityBridge _live;

  static const _channelId = 'focus_journey';
  static const _channelName = '집중 여정';
  static const _progressId = 1001;
  static const _arriveId = 1002;

  bool _initialized = false;
  bool _liveStarted = false;

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (_initialized || !_mobile) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );
    try {
      await _fln.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      await _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (_) {}
  }

  /// 여정 시작. 진행 알림/Live Activity 시작.
  Future<void> start({
    required String origin,
    required String dest,
    required String transportEmoji,
    required int startMs,
    required int endMs,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_mobile) return;
    await init();
    await _showAndroidProgress(
        origin, dest, transportEmoji, endMs, false, remainingSeconds, progress);
    final id = await _live.start(
      origin: origin,
      dest: dest,
      transportEmoji: transportEmoji,
      startMs: startMs,
      endMs: endMs,
      paused: false,
      remainingSeconds: remainingSeconds,
      progress: progress,
    );
    _liveStarted = id != null;
  }

  /// 일시정지/재개 시 갱신. (running 이면 startMs/endMs 를 새로 계산해 넘긴다)
  Future<void> update({
    required String origin,
    required String dest,
    required String transportEmoji,
    required int startMs,
    required int endMs,
    required bool paused,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_mobile) return;
    await _showAndroidProgress(
        origin, dest, transportEmoji, endMs, paused, remainingSeconds, progress);
    if (_liveStarted) {
      await _live.update(
        startMs: startMs,
        endMs: endMs,
        paused: paused,
        remainingSeconds: remainingSeconds,
        progress: progress,
      );
    }
  }

  Future<void> _showAndroidProgress(String origin, String dest, String emoji,
      int endMs, bool paused, int remainingSeconds, double progress) async {
    if (!Platform.isAndroid) return;
    final percent = (progress * 100).round().clamp(0, 100);
    final details = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '집중 여정 진행 상황',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      progress: percent,
      category: AndroidNotificationCategory.progress,
      // 진행 중이면 chronometer 로 매초 자동 카운트다운(앱 갱신 불필요).
      when: paused ? null : endMs,
      usesChronometer: !paused,
      chronometerCountDown: true,
    );
    try {
      await _fln.show(
        _progressId,
        '$emoji $origin → $dest',
        paused ? '일시정지 · ${_clock(remainingSeconds)} 남음' : '집중 여정 진행 중',
        NotificationDetails(android: details),
      );
    } catch (_) {}
  }

  /// 도착. 진행 알림을 지우고 완료 알림을 띄운다.
  Future<void> arrived({
    required String dest,
    String? collectibleName,
  }) async {
    if (!_mobile) return;
    try {
      await _fln.cancel(_progressId);
      await _fln.show(
        _arriveId,
        '$dest에 도착했어요 🎉',
        collectibleName != null
            ? '집중 여정 완료 · "$collectibleName" 획득!'
            : '집중 여정 완료',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: '집중 여정 진행 상황',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {}
    // _liveStarted 와 무관하게 종료를 호출해, 재실행으로 남은 유령 활동도 정리.
    await _live.end(arrivedAt: dest);
    _liveStarted = false;
  }

  /// 중단/취소. 모든 진행 알림과 Live Activity 제거.
  Future<void> cancel() async {
    if (!_mobile) return;
    try {
      await _fln.cancel(_progressId);
    } catch (_) {}
    // _liveStarted 와 무관하게 종료를 호출해, 재실행으로 남은 유령 활동도 정리.
    await _live.end();
    _liveStarted = false;
  }

  static String _clock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    if (m >= 60) {
      final h = m ~/ 60;
      return '$h:${two(m % 60)}:${two(s)}';
    }
    return '${two(m)}:${two(s)}';
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
