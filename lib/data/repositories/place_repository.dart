import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../models/transport_type.dart';
import '../static/airports.dart';
import '../static/stations.dart';
import '../static/terminals.dart';

/// 교통수단별 장소 목록 제공 및 검색.
class PlaceRepository {
  const PlaceRepository();

  List<Place> byTransport(TransportType type) => switch (type) {
        TransportType.train => trainStations,
        TransportType.bus => busTerminals,
        TransportType.airplane => airports,
      };

  /// 이름 또는 도시명으로 검색. 빈 검색어는 전체 반환.
  List<Place> search(TransportType type, String query) {
    final all = byTransport(type);
    final q = query.trim();
    if (q.isEmpty) return all;
    return all.where((p) => p.name.contains(q) || p.city.contains(q)).toList();
  }

  /// 출발지를 제외한 도착지 후보.
  List<Place> destinationsFor(TransportType type, Place origin) =>
      byTransport(type).where((p) => p.id != origin.id).toList();
}

final placeRepositoryProvider =
    Provider<PlaceRepository>((ref) => const PlaceRepository());
