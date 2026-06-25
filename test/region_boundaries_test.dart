import 'package:flutter_test/flutter_test.dart';
import 'package:korean_focus/features/focus/region_boundaries.dart';

void main() {
  group('parseBoundaryGeoJson', () {
    test('Polygon: 외곽선과 구멍을 분리한다', () {
      const raw = '''
      {"type":"FeatureCollection","features":[
        {"type":"Feature","properties":{"name":"테스트시"},
         "geometry":{"type":"Polygon","coordinates":[
           [[127.0,37.0],[127.1,37.0],[127.1,37.1],[127.0,37.1],[127.0,37.0]],
           [[127.04,37.04],[127.06,37.04],[127.06,37.06],[127.04,37.04]]
         ]}}
      ]}''';
      final polys = parseBoundaryGeoJson(raw);
      expect(polys.length, 1);
      expect(polys.first.outer.length, 5);
      expect(polys.first.holes.length, 1);
      // GeoJSON [lng,lat] → LatLng(lat,lng) 순서 변환 확인.
      expect(polys.first.outer.first.latitude, 37.0);
      expect(polys.first.outer.first.longitude, 127.0);
    });

    test('MultiPolygon: 각 폴리곤을 개별 항목으로 펼친다', () {
      const raw = '''
      {"type":"FeatureCollection","features":[
        {"type":"Feature","properties":{"name":"섬많은군"},
         "geometry":{"type":"MultiPolygon","coordinates":[
           [[[126.0,34.0],[126.1,34.0],[126.1,34.1],[126.0,34.0]]],
           [[[126.5,34.5],[126.6,34.5],[126.6,34.6],[126.5,34.5]]]
         ]}}
      ]}''';
      final polys = parseBoundaryGeoJson(raw);
      expect(polys.length, 2);
      expect(polys.every((p) => p.holes.isEmpty), isTrue);
    });
  });
}
