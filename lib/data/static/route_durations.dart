import '../../core/utils/geo.dart';
import '../models/journey_route.dart';
import '../models/place.dart';
import '../models/transport_type.dart';

class RouteInfo {
  final int minutes;
  final String grade;
  const RouteInfo(this.minutes, this.grade);
}

/// 키: '출발id>도착id' (양방향 모두 조회). MVP용 정적 소요시간 테이블.
const _staticDurations = <String, RouteInfo>{
  // 기차 (KTX 기준)
  'jeonju_st>seoul_st': RouteInfo(100, 'KTX'),
  'iksan_st>seoul_st': RouteInfo(95, 'KTX'),
  'busan_st>seoul_st': RouteInfo(160, 'KTX'),
  'dongdaegu_st>seoul_st': RouteInfo(110, 'KTX'),
  'gwangju_songjeong_st>seoul_st': RouteInfo(95, 'KTX'),
  'daejeon_st>seoul_st': RouteInfo(60, 'KTX'),
  'gangneung_st>seoul_st': RouteInfo(120, 'KTX'),
  'mokpo_st>seoul_st': RouteInfo(150, 'KTX'),
  'busan_st>dongdaegu_st': RouteInfo(50, 'KTX'),
  // 버스 (고속)
  'jeonju_term>seoul_express_term': RouteInfo(165, '고속'),
  'gwangju_term>seoul_express_term': RouteInfo(210, '고속'),
  'busan_term>seoul_express_term': RouteInfo(250, '고속'),
  'daejeon_term>seoul_express_term': RouteInfo(130, '고속'),
  'gangneung_term>seoul_express_term': RouteInfo(175, '고속'),
  // 비행기 (직항)
  'gimpo_ap>jeju_ap': RouteInfo(70, '직항'),
  'gimhae_ap>jeju_ap': RouteInfo(60, '직항'),
  'incheon_ap>jeju_ap': RouteInfo(75, '직항'),
  'gimpo_ap>gimhae_ap': RouteInfo(60, '직항'),
};

/// 정적 테이블 우선, 없으면 거리 기반으로 소요시간 추정.
RouteInfo lookupRouteInfo(Place origin, Place destination, TransportType transport) {
  final hit = _staticDurations['${origin.id}>${destination.id}'] ??
      _staticDurations['${destination.id}>${origin.id}'];
  if (hit != null) return hit;

  final km = haversineKm(origin.lat, origin.lng, destination.lat, destination.lng);
  final (speedKmh, grade) = switch (transport) {
    TransportType.bus => (75.0, '고속'),
    TransportType.train => (140.0, 'KTX'),
    TransportType.airplane => (600.0, '직항'),
  };
  final minutes = (km / speedKmh * 60).round().clamp(20, 240);
  return RouteInfo(minutes, grade);
}

JourneyRoute buildRoute(Place origin, Place destination, TransportType transport) {
  final info = lookupRouteInfo(origin, destination, transport);
  return JourneyRoute(
    origin: origin,
    destination: destination,
    transport: transport,
    durationMinutes: info.minutes,
    grade: info.grade,
  );
}
