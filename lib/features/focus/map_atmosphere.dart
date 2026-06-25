import 'package:flutter/material.dart';

/// 감성 지도의 시간대 분위기(아침·낮·저녁·밤).
///
/// 집중을 시작한 실제 시각에 따라 하늘·땅·항로·천체(해·달·별) 색을 바꾼다.
/// 색은 모두 하드코딩(물리적 장면) — 라이트/다크 모드와 무관하게 일정하다.
class MapAtmosphere {
  const MapAtmosphere({
    required this.label,
    required this.icon,
    required this.sky,
    required this.stops,
    required this.landFill,
    required this.landStroke,
    required this.trailFaint,
    required this.trailGlow,
    required this.trailBright,
    required this.originDot,
    required this.destFill,
    required this.destRing,
    required this.vehicleGlow,
    this.sun,
    this.moon = false,
    this.stars = 0,
  });

  final String label;
  final IconData icon;

  /// 하늘 그라데이션(위→아래) 색과 정지점.
  final List<Color> sky;
  final List<double> stops;

  /// 땅(행정구역) 채움/경계.
  final Color landFill;
  final Color landStroke;

  /// 항로: 남은(점선)·지나온(글로우)·지나온(선).
  final Color trailFaint;
  final Color trailGlow;
  final Color trailBright;

  /// 출발 점 / 도착 채움 / 도착 링 / 차량 글로우.
  final Color originDot;
  final Color destFill;
  final Color destRing;
  final Color vehicleGlow;

  /// 해(위치는 캔버스 비율 0~1). null이면 안 그림.
  final ({double x, double y, double r, Color color})? sun;
  final bool moon;
  final int stars;

  /// 실제 시각(시)으로 분위기 선택.
  static MapAtmosphere forHour(int hour) {
    if (hour >= 5 && hour < 9) return morning;
    if (hour >= 9 && hour < 17) return day;
    if (hour >= 17 && hour < 20) return dusk;
    return night;
  }

  /// 아침 — 옅은 보랏빛에서 복숭아 지평선으로, 떠오르는 해.
  static const morning = MapAtmosphere(
    label: '아침',
    icon: Icons.wb_twilight,
    sky: [Color(0xFF9FB6D6), Color(0xFFE9C6A4), Color(0xFFFBEACB)],
    stops: [0.0, 0.52, 1.0],
    landFill: Color(0xD9263528),
    landStroke: Color(0x55F1C98A),
    trailFaint: Color(0x66F4B98A),
    trailGlow: Color(0x40FFD8A0),
    trailBright: Color(0xFFFFC97A),
    originDot: Color(0xFFFFF3DA),
    destFill: Color(0xFF2A3A4E),
    destRing: Color(0xFFFFC97A),
    vehicleGlow: Color(0x80FFD8A0),
    sun: (x: 0.80, y: 0.30, r: 12.0, color: Color(0xFFFFE7B8)),
  );

  /// 낮 — 맑은 하늘, 높이 뜬 해, 황톳빛 항로.
  static const day = MapAtmosphere(
    label: '낮',
    icon: Icons.light_mode,
    sky: [Color(0xFF7FB2DC), Color(0xFFBBD8E6), Color(0xFFE9EBD8)],
    stops: [0.0, 0.5, 1.0],
    landFill: Color(0xE63B4A2C),
    landStroke: Color(0x59F0DBA6),
    trailFaint: Color(0x66C98A3A),
    trailGlow: Color(0x40E3A646),
    trailBright: Color(0xFFBA7517),
    originDot: Color(0xFFFFF7E9),
    destFill: Color(0xFFEDE7D2),
    destRing: Color(0xFFBA7517),
    vehicleGlow: Color(0x66E3A646),
    sun: (x: 0.82, y: 0.18, r: 11.0, color: Color(0xFFFFF1C8)),
  );

  /// 저녁(노을) — 깊은 남색에서 노을빛 지평선, 지는 해 + 초저녁 별.
  static const dusk = MapAtmosphere(
    label: '저녁',
    icon: Icons.brightness_4,
    sky: [Color(0xFF243049), Color(0xFF3C4663), Color(0xFF9A6B53)],
    stops: [0.0, 0.58, 1.0],
    landFill: Color(0xD916242A),
    landStroke: Color(0x4DE3A646),
    trailFaint: Color(0x66F2B45C),
    trailGlow: Color(0x40F4C06A),
    trailBright: Color(0xFFF4C06A),
    originDot: Color(0xFFF6E4B8),
    destFill: Color(0xFF243049),
    destRing: Color(0xFFF4C06A),
    vehicleGlow: Color(0x80F4C06A),
    sun: (x: 0.17, y: 0.64, r: 15.0, color: Color(0xFFE9914A)),
    stars: 2,
  );

  /// 밤 — 짙은 남색 하늘, 달과 별, 등불 같은 금빛 항로.
  static const night = MapAtmosphere(
    label: '밤',
    icon: Icons.dark_mode,
    sky: [Color(0xFF0E1524), Color(0xFF18203A), Color(0xFF2A3150)],
    stops: [0.0, 0.6, 1.0],
    landFill: Color(0xF20B1116),
    landStroke: Color(0x4D8FA6C4),
    trailFaint: Color(0x66E9C77A),
    trailGlow: Color(0x4DF4D08A),
    trailBright: Color(0xFFF6D98A),
    originDot: Color(0xFFFFF3DA),
    destFill: Color(0xFF0E1524),
    destRing: Color(0xFFF6D98A),
    vehicleGlow: Color(0x99F6D98A),
    moon: true,
    stars: 12,
  );
}
