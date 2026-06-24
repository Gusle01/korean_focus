import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

/// 행정구역 경계 폴리곤 1개(외곽선 + 구멍).
class BoundaryPolygon {
  final List<LatLng> outer;
  final List<List<LatLng>> holes;

  const BoundaryPolygon({required this.outer, this.holes = const []});
}

List<LatLng> _ring(List<dynamic> coords) => [
      for (final p in coords)
        LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()),
    ];

List<BoundaryPolygon> _parsePolygon(List<dynamic> rings) {
  if (rings.isEmpty) return const [];
  final outer = _ring(rings.first as List<dynamic>);
  final holes = [
    for (final h in rings.skip(1)) _ring(h as List<dynamic>),
  ];
  return [BoundaryPolygon(outer: outer, holes: holes)];
}

List<BoundaryPolygon> _parseFeature(Map<String, dynamic> geom) {
  final type = geom['type'] as String;
  final coords = geom['coordinates'] as List<dynamic>;
  if (type == 'Polygon') {
    return _parsePolygon(coords);
  }
  if (type == 'MultiPolygon') {
    return [
      for (final poly in coords) ..._parsePolygon(poly as List<dynamic>),
    ];
  }
  return const [];
}

/// GeoJSON FeatureCollection 문자열을 경계 폴리곤 목록으로 파싱.
List<BoundaryPolygon> parseBoundaryGeoJson(String raw) {
  final data = json.decode(raw) as Map<String, dynamic>;
  final features = data['features'] as List<dynamic>;
  final result = <BoundaryPolygon>[];
  for (final f in features) {
    final geom = (f as Map<String, dynamic>)['geometry'];
    if (geom is Map<String, dynamic>) {
      result.addAll(_parseFeature(geom));
    }
  }
  return result;
}

/// 번들된 행정구역 GeoJSON을 파싱해 캐싱한다(도/시군구 2단계).
class KoreaBoundaries {
  KoreaBoundaries._();

  static Future<List<BoundaryPolygon>>? _provinces;
  static Future<List<BoundaryPolygon>>? _municipalities;

  /// 시·도(광역) 경계 — 줌이 낮을 때 표시.
  static Future<List<BoundaryPolygon>> provinces() =>
      _provinces ??= _load('assets/geo/kr-provinces.json');

  /// 시·군·구 경계 — 줌이 높을 때 표시.
  static Future<List<BoundaryPolygon>> municipalities() =>
      _municipalities ??= _load('assets/geo/kr-municipalities.json');

  static Future<List<BoundaryPolygon>> _load(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return parseBoundaryGeoJson(raw);
  }
}
