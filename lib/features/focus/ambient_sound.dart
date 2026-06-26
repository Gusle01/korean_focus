import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transport_type.dart';

/// 집중 중 교통수단 배경음 on/off (기본 off, 세션 간 유지).
final ambientEnabledProvider = StateProvider<bool>((ref) => false);

const _assetFor = {
  TransportType.bus: 'audio/bus.wav',
  TransportType.train: 'audio/train.wav',
  TransportType.airplane: 'audio/airplane.wav',
};

/// 교통수단별 앰비언트 루프를 재생/일시정지/정지한다.
/// (합성 음원 — 추후 실제 녹음으로 교체 가능. 오류는 조용히 무시.)
class AmbientSoundController {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  static const double _volume = 0.55;

  Future<void> play(TransportType t) async {
    final asset = _assetFor[t];
    if (asset == null) return;
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
      await _player.play(AssetSource(asset), volume: _volume);
      _playing = true;
    } catch (_) {}
  }

  Future<void> pause() async {
    if (!_playing) return;
    try {
      await _player.pause();
    } catch (_) {}
  }

  Future<void> resume() async {
    if (!_playing) return;
    try {
      await _player.resume();
    } catch (_) {}
  }

  Future<void> stop() async {
    _playing = false;
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {}
  }
}

final ambientSoundProvider = Provider<AmbientSoundController>((ref) {
  final controller = AmbientSoundController();
  ref.onDispose(controller.dispose);
  return controller;
});
