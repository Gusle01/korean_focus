import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'live_activity_bridge.dart';

/// 집중 여정의 실시간 상태를 OS 알림으로 보여준다.
///
/// - Android: 잠금화면/알림센터에 진행률이 표시되는 지속(ongoing) 알림.
/// - iOS: 도착 알림(로컬 알림) + 진행 중 Live Activity(다이나믹 아일랜드/잠금화면).
///   Live Activity 는 위젯 익스텐션이 설정돼 있을 때만 표시된다.
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
      // Android 13+ 알림 권한 요청.
      await _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (_) {
      // 테스트/미지원 환경 등에서는 조용히 무시.
    }
  }

  AndroidNotificationDetails _androidProgress(int percent) =>
      AndroidNotificationDetails(
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
        progress: percent.clamp(0, 100),
        category: AndroidNotificationCategory.progress,
      );

  /// 여정 시작. 진행 알림/Live Activity 를 띄운다.
  Future<void> start({
    required String origin,
    required String dest,
    required String transportEmoji,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_mobile) return;
    await init();
    // Android: 진행률이 보이는 지속 알림. iOS: 반복 배너 대신 Live Activity 사용.
    await _showAndroidProgress(origin, dest, transportEmoji, remainingSeconds,
        progress);
    final id = await _live.start(
      origin: origin,
      dest: dest,
      transportEmoji: transportEmoji,
      remainingSeconds: remainingSeconds,
      progress: progress,
    );
    _liveStarted = id != null;
  }

  /// 진행 상황 갱신. (1초마다가 아니라 표시값이 바뀔 때만 호출하는 것을 권장)
  Future<void> update({
    required String origin,
    required String dest,
    required String transportEmoji,
    required int remainingSeconds,
    required double progress,
  }) async {
    if (!_mobile) return;
    await _showAndroidProgress(origin, dest, transportEmoji, remainingSeconds,
        progress);
    if (_liveStarted) {
      await _live.update(remainingSeconds: remainingSeconds, progress: progress);
    }
  }

  Future<void> _showAndroidProgress(String origin, String dest,
      String transportEmoji, int remainingSeconds, double progress) async {
    if (!Platform.isAndroid) return;
    final percent = (progress * 100).round();
    try {
      await _fln.show(
        _progressId,
        '$transportEmoji $origin → $dest',
        '${_clock(remainingSeconds)} 남음',
        NotificationDetails(android: _androidProgress(percent)),
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
        NotificationDetails(
          android: const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: '집중 여정 진행 상황',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (_) {}
    if (_liveStarted) {
      await _live.end(arrivedAt: dest);
      _liveStarted = false;
    }
  }

  /// 중단/취소. 모든 진행 알림과 Live Activity 제거.
  Future<void> cancel() async {
    if (!_mobile) return;
    try {
      await _fln.cancel(_progressId);
    } catch (_) {}
    if (_liveStarted) {
      await _live.end();
      _liveStarted = false;
    }
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
