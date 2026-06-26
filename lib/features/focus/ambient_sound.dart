import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/models/transport_type.dart';

/// 배경음 믹스 레이어. transport(현재 교통수단 이동음) + 자연음 오버레이.
enum AmbientLayer { transport, rain, waves, stream }

extension AmbientLayerX on AmbientLayer {
  String get label => switch (this) {
        AmbientLayer.transport => '이동음',
        AmbientLayer.rain => '빗소리',
        AmbientLayer.waves => '파도',
        AmbientLayer.stream => '시냇물',
      };

  String get emoji => switch (this) {
        AmbientLayer.transport => '🚆',
        AmbientLayer.rain => '🌧️',
        AmbientLayer.waves => '🌊',
        AmbientLayer.stream => '🏞️',
      };

  /// 레이어별 기준 볼륨(마스터 볼륨에 곱함). 자연음이 이동음을 덮지 않게 보정.
  double get gain => switch (this) {
        AmbientLayer.transport => 1.0,
        AmbientLayer.rain => 0.9,
        AmbientLayer.waves => 0.85,
        AmbientLayer.stream => 0.8,
      };
}

const _overlayAsset = {
  AmbientLayer.rain: 'audio/rain.wav',
  AmbientLayer.waves: 'audio/waves.wav',
  AmbientLayer.stream: 'audio/stream.wav',
};
const _transportAsset = {
  TransportType.bus: 'audio/bus.wav',
  TransportType.train: 'audio/train.wav',
  TransportType.airplane: 'audio/airplane.wav',
};

String? _assetOf(AmbientLayer layer, TransportType transport) =>
    layer == AmbientLayer.transport
        ? _transportAsset[transport]
        : _overlayAsset[layer];

// ── 설정 영속화(볼륨/레이어) ─────────────────────────────────────────
const ambientSettingsBoxName = 'settings';
const _kVolume = 'ambientVolume';
const _kLayers = 'ambientLayers';
const double _defaultVolume = 0.55;
const Set<AmbientLayer> _defaultLayers = {AmbientLayer.transport};

double _readVolume() {
  if (!Hive.isBoxOpen(ambientSettingsBoxName)) return _defaultVolume;
  final v = Hive.box(ambientSettingsBoxName).get(_kVolume);
  return v is num ? v.toDouble().clamp(0.0, 1.0) : _defaultVolume;
}

Set<AmbientLayer> _readLayers() {
  if (!Hive.isBoxOpen(ambientSettingsBoxName)) return {..._defaultLayers};
  final raw = Hive.box(ambientSettingsBoxName).get(_kLayers);
  if (raw is List) {
    final s = <AmbientLayer>{};
    for (final e in raw) {
      final i = e is int ? e : int.tryParse('$e');
      if (i != null && i >= 0 && i < AmbientLayer.values.length) {
        s.add(AmbientLayer.values[i]);
      }
    }
    return s;
  }
  return {..._defaultLayers};
}

/// 볼륨/레이어 설정을 저장(세션 간 유지).
Future<void> persistAmbientSettings(
    double volume, Set<AmbientLayer> layers) async {
  if (!Hive.isBoxOpen(ambientSettingsBoxName)) return;
  final box = Hive.box(ambientSettingsBoxName);
  await box.put(_kVolume, volume);
  await box.put(_kLayers, layers.map((l) => l.index).toList());
}

/// 집중 중 배경음 master on/off (기본 off, 세션 단위 — 영속하지 않음).
final ambientEnabledProvider = StateProvider<bool>((ref) => false);

/// 마스터 볼륨(0~1, 영속).
final ambientVolumeProvider = StateProvider<double>((ref) => _readVolume());

/// 켜진 믹스 레이어(영속).
final ambientLayersProvider =
    StateProvider<Set<AmbientLayer>>((ref) => _readLayers());

/// 여러 배경음 레이어를 동시에 재생/믹스하는 컨트롤러.
/// (합성 음원 — 추후 실제 녹음으로 교체 가능. 오류는 조용히 무시.)
class AmbientMixer {
  final Map<AmbientLayer, AudioPlayer> _players = {};

  Future<void> _safe(Future<void> Function() f) async {
    try {
      await f();
    } catch (_) {}
  }

  /// 활성 레이어 집합 + 볼륨을 현재 상태에 맞춘다(없으면 추가, 빠지면 정지).
  Future<void> apply({
    required TransportType transport,
    required Set<AmbientLayer> active,
    required double volume,
    required bool paused,
  }) async {
    // 빠진 레이어 정지
    for (final l in _players.keys.toList()) {
      if (!active.contains(l)) {
        final p = _players.remove(l);
        await _safe(() => p!.stop());
        await _safe(() => p!.dispose());
      }
    }
    // 활성 레이어 시작/볼륨 갱신
    for (final l in active) {
      final asset = _assetOf(l, transport);
      if (asset == null) continue;
      final vol = (volume * l.gain).clamp(0.0, 1.0).toDouble();
      final existing = _players[l];
      if (existing == null) {
        final p = AudioPlayer();
        _players[l] = p;
        await _safe(() async {
          await p.setReleaseMode(ReleaseMode.loop);
          await p.play(AssetSource(asset), volume: vol);
          if (paused) await p.pause();
        });
      } else {
        await _safe(() => existing.setVolume(vol));
      }
    }
  }

  Future<void> setVolume(double volume) async {
    for (final e in _players.entries) {
      final vol = (volume * e.key.gain).clamp(0.0, 1.0).toDouble();
      await _safe(() => e.value.setVolume(vol));
    }
  }

  Future<void> pause() async {
    for (final p in _players.values) {
      await _safe(() => p.pause());
    }
  }

  Future<void> resume() async {
    for (final p in _players.values) {
      await _safe(() => p.resume());
    }
  }

  Future<void> stop() async {
    for (final l in _players.keys.toList()) {
      final p = _players.remove(l);
      await _safe(() => p!.stop());
      await _safe(() => p!.dispose());
    }
  }

  Future<void> dispose() async => stop();
}

final ambientSoundProvider = Provider<AmbientMixer>((ref) {
  final mixer = AmbientMixer();
  ref.onDispose(mixer.dispose);
  return mixer;
});
