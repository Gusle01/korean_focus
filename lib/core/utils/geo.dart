import 'dart:math';

/// 두 좌표 사이의 대원(great-circle) 거리(km). 소요시간 추정 폴백에 사용.
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const radiusKm = 6371.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  return radiusKm * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _toRad(double deg) => deg * pi / 180;
