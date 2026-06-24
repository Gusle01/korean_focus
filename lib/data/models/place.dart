import 'transport_type.dart';

/// 출발지/도착지가 되는 장소(역·터미널·공항).
class Place {
  final String id;
  final String name; // 예: 전주역
  final String city; // 예: 전주
  final TransportType type;
  final double lat;
  final double lng;

  const Place({
    required this.id,
    required this.name,
    required this.city,
    required this.type,
    required this.lat,
    required this.lng,
  });
}
